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
public class WinPage : Gtk.AspectFrame {
	private Gtk.Label error_label;
	private Gtk.Label points_label;
	private Gtk.Label highscore_label;
	public signal void return_to_welcome ();

	public WinPage () {
		set_shadow_type (Gtk.ShadowType.IN);
		var grid = new Gtk.Grid ();
		grid.column_homogeneous = true;
		this.add (grid);

		var error_text = new Gtk.Label (_("Errors:"));
		error_text.get_style_context ().add_class ("win-label");
		error_text.margin = 20;
		error_text.margin_bottom = 50;
		grid.attach (error_text, 0, 0, 1, 1);
		error_label = new Gtk.Label ("");
		error_label.get_style_context ().add_class ("win-label");
		grid.attach (error_label, 1, 0, 1, 1);

		var points_text = new Gtk.Label (_("Result:"));
		points_text.get_style_context ().add_class ("win-label");
		grid.attach (points_text, 0, 2, 1, 1);
		points_label = new Gtk.Label ("");
		points_label.get_style_context ().add_class ("win-label");
		grid.attach (points_label, 1, 2, 1, 1);

		var highscore_text = new Gtk.Label (_("Highscore:"));
		highscore_text.get_style_context ().add_class ("win-label");
		grid.attach (highscore_text, 0, 3, 1, 1);
		highscore_label = new Gtk.Label ("");
		highscore_label.get_style_context ().add_class ("win-label");
		grid.attach (highscore_label, 1, 3, 1, 1);

		var button = new Gtk.Button.with_label (_("New Game"));
		button.get_style_context ().add_class ("win-label");
		button.get_style_context ().add_class ("win-button");
		button.margin = 20;
		button.clicked.connect (() => {
			return_to_welcome ();
		});
		grid.attach (button, 0, 6, 1, 1);
	}

	public void set_board (SudokuBoard board, int highscore) {
		if (board.fails == 0) {
			error_label.set_markup ("<b>"+_("none!")+"</b>\n"+_("perfect!"));
		} else {
			string tmp = "";
			for (var i = 0; i < board.fails; i++) {
				tmp += "X";
			}
			error_label.set_markup ("<span face=\"Daniel Black\" weight=\"bold\">"+tmp+"</span>");
		}
		points_label.set_markup ("<b>%i</b>".printf (board.points));
		highscore_label.set_markup ("<b>%i</b>".printf (highscore));
	}
}
}