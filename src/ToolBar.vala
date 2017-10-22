/*
 * Copyright (c) 2017 Peter Arnold
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */
 
namespace Sudoku {
	public class ToolBar : Gtk.HeaderBar {
		private Gtk.Label points;
		private Gtk.Label factor;
		private Gtk.Label fails;

		public ToolBar () {
			var header_context = this.get_style_context ();
            header_context.add_class ("sudoku-toolbar");
            this.show_close_button = true;
            points = new Gtk.Label ("");
            points.get_style_context ().add_class ("h3");
            points.visible = false;
            points.margin_left = 40;
            factor = new Gtk.Label ("");
            factor.get_style_context ().add_class ("h3");
            factor.visible = false;
            factor.margin_right = 80;
            fails = new Gtk.Label ("");
            fails.visible = false;
            pack_start (points);
            pack_end (factor);
            set_custom_title (fails);
		}

		public void set_board (SudokuBoard board) {
			points.visible = true;
			factor.visible = true;
			fails.visible = true;
			board.notify["points"].connect ((s, p) => {
				points.set_markup ("<b>%i</b>".printf (board.points));
			});
			board.notify["factor"].connect ((s, p) => {
				factor.set_markup ("<b>x%i</b>".printf (board.factor));
			});
			board.notify["fails"].connect ((s, p) => {
				set_fail (board);
			});
			set_fail (board);
			points.set_markup ("<b>%i</b>".printf (board.points));
			factor.set_markup ("<b>x%i</b>".printf (board.factor));
			show_all ();
		}

		private void set_fail (SudokuBoard board) {
			if (board.fails > 3) {
				string tmp = "%i ".printf (board.fails);
				tmp += _("broken series");
				fails.set_markup ("<span foreground=\"red\" weight=\"bold\">"+tmp+"</span>");
				fails.margin_top = 0;
			} else {
				string tmp = "";
				for (var i = 0; i < board.fails; i++) {
					tmp += "X";
				}
				fails.set_markup ("<span face=\"Daniel Black\" weight=\"bold\">"+tmp+"</span>");
				fails.margin_top = 10;
			}
		}

		public void reset () {
			points.visible = false;
			factor.visible = false;
			fails.visible = false;
		}
	}
}