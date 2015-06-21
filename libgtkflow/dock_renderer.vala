/********************************************************************
# Copyright 2014 Daniel 'grindhold' Brendle
#
# This file is part of libgtkflow.
#
# libgtkflow is free software: you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public License
# as published by the Free Software Foundation, either
# version 3 of the License, or (at your option) any later
# version.
#
# libgtkflow is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with libgtkflow.
# If not, see http://www.gnu.org/licenses/.
*********************************************************************/

namespace GtkFlow {
    public abstract class DockRenderer : GLib.Object {
        public int dockpoint_height {get;set;default=16;}
        public int spacing_x {get; set; default=5;}
        public int spacing_y {get; set; default=3;}

        public signal void size_changed();

        public abstract void draw_dock(Cairo.Context cr, Gtk.StyleContext sc,
                                         int offset_x, int offset_y, int width);
        public abstract int get_min_height();
        public abstract int get_min_width();
        public abstract void update_name_layout(bool show_types);
        public abstract GFlow.Dock get_dock();
    }

    private class DefaultDockRenderer : DockRenderer {
        private Pango.Layout layout = null;
        private GFlow.Dock d = null;

        public DefaultDockRenderer(Node n, GFlow.Dock d) {
            this.d = d;
            this.layout = (new Gtk.Label("")).create_pango_layout("");
        }

        public override GFlow.Dock get_dock () {
            return this.d;
        }

        public override void update_name_layout(bool show_types) {
            string labelstring;
            if (show_types) {
                labelstring = "<i>%s</i> : %s".printf(
                    this.d.typename ?? this.d.determine_typestring(),
                    this.d.name
                );
            } else {
                labelstring = this.d.name;
            }
            this.layout.set_markup(labelstring, -1);
            this.size_changed();
        }

        /**
         * Get the minimum width for this dock
         */
        public override int get_min_height() {
            int width, height;
            this.layout.get_pixel_size(out width, out height);
            return (int)(Math.fmax(height, dockpoint_height))+spacing_y;
        }

        /**
         * Get the minimum height for this dock
         */
        public override int get_min_width() {
            int width, height;
            this.layout.get_pixel_size(out width, out height);
            return (int)(width + dockpoint_height + spacing_y);
        }

        public override void draw_dock(Cairo.Context cr, Gtk.StyleContext sc,
                                       int offset_x, int offset_y, int width) {
            if (d is GFlow.Sink)
                draw_sink(cr, sc, offset_x, offset_y, width);
            if (d is GFlow.Source)
                draw_source(cr, sc, offset_x, offset_y, width);
        }

        /**
         * Draw the given source onto a cairo context
         */
        public void draw_source(Cairo.Context cr, Gtk.StyleContext sc,
                                int offset_x, int offset_y, int width) {
            sc.save();
            if (this.d.is_connected())
                sc.set_state(Gtk.StateFlags.CHECKED);
            if (this.d.highlight)
                sc.set_state(sc.get_state() | Gtk.StateFlags.PRELIGHT);
            if (this.d.active)
                sc.set_state(sc.get_state() | Gtk.StateFlags.ACTIVE);
            sc.add_class(Gtk.STYLE_CLASS_RADIO);
            sc.render_option(cr, offset_x+width-dockpoint_height,offset_y,dockpoint_height,dockpoint_height);
            sc.restore();
            sc.save();
            sc.add_class(Gtk.STYLE_CLASS_BUTTON);
            Gdk.RGBA col = sc.get_color(Gtk.StateFlags.NORMAL);
            cr.set_source_rgba(col.red,col.green,col.blue,col.alpha);
            cr.move_to(offset_x + width - this.get_min_width(), offset_y);
            Pango.cairo_show_layout(cr, this.layout);
            sc.restore();
        }

        /**
         * Draw the given sink onto a cairo context
         */
        public void draw_sink(Cairo.Context cr, Gtk.StyleContext sc,
                              int offset_x, int offset_y, int width) {
            sc.save();
            if (this.d.is_connected())
                sc.set_state(Gtk.StateFlags.CHECKED);
            if (this.d.highlight)
                sc.set_state(sc.get_state() | Gtk.StateFlags.PRELIGHT);
            if (this.d.active)
                sc.set_state(sc.get_state() | Gtk.StateFlags.ACTIVE);
            sc.add_class(Gtk.STYLE_CLASS_RADIO);
            sc.render_option(cr, offset_x,offset_y,dockpoint_height,dockpoint_height);
            sc.restore();
            sc.save();
            sc.add_class(Gtk.STYLE_CLASS_BUTTON);
            Gdk.RGBA col = sc.get_color(Gtk.StateFlags.NORMAL);
            cr.set_source_rgba(col.red,col.green,col.blue,col.alpha);
            cr.move_to(offset_x+dockpoint_height+spacing_x, offset_y);
            Pango.cairo_show_layout(cr, this.layout);
            sc.restore();
        }
    }
}
