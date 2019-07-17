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

    public class MainWindow : Gtk.Window {
    	private SudokuSettings settings;
        private Gtk.Stack stack;
        private Granite.Widgets.Welcome welcome;
        private Gtk.Box welcome_box;
        private SudokuBoard sudoku_board;
        private WinPage win_page;

		public MainWindow (Gtk.Application application) {
			Object (application: application,
                icon_name: "com.github.parnold-x.sudoku",
                resizable: false,
                title: _("Sudoku"),
                height_request: 700,
				width_request: 800);
        }

        construct {
            try {
            var provider = new Gtk.CssProvider ();
            provider.load_from_data ("
.welcome {
    background: transparent;
}
.win-label {
   font-size: 20px;
   margin: 10px;
}
GtkInfoBar {
    background-color: shade (mix (rgb (67%, 13%, 16%), rgb (67%, 13%, 16%), 0.6), 1);
}
.win-button {
    border-color: shade (mix (rgb (67%, 13%, 16%), rgb (67%, 13%, 16%), 0.6), 1);
}
");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            } catch (Error e) {
                 error (e.message);
            }
            this.get_style_context ().add_class ("sudoku-window");

            var toolbar = new ToolBar ();
            set_titlebar (toolbar);

            this.delete_event.connect (on_window_closing);

        	this.settings = new SudokuSettings ();
        	stack = new Gtk.Stack ();
            stack.margin_top = 15;
            stack.margin_bottom = 15;
            welcome_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        	welcome = new Granite.Widgets.Welcome ("", _("Choose difficulty"));
        	foreach (Difficulty diff in Difficulty.all ()) {
        		welcome.append ("",diff.to_translated_string (), "");
        	}
            win_page = new WinPage ();
            win_page.return_to_welcome.connect (() => {
                stack.set_visible_child (welcome_box);
            });
            Gtk.Image image = new Gtk.Image.from_resource ("/com/github/parnold-x/sudoku/header.png");
            welcome_box.pack_start (image);
            welcome_box.pack_end (welcome);
        	stack.add_named (welcome_box, "welcome");
            stack.add_named (win_page, "win");
            var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            main_box.pack_end (stack, false, true, 0);
            this.add (main_box);
            var info_bar = new Gtk.InfoBar ();
            if (settings.isSaved ()) {
                sudoku_board = new SudokuBoard.from_string (settings.load ());
                if (!sudoku_board.isFinshed ()) {
                    info_bar.set_message_type (Gtk.MessageType.ERROR);
                    main_box.pack_end (info_bar, false, true, 0);
                    var content = info_bar.get_content_area ();
                    var infobox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 20);
                    content.add (infobox);
                    var button = new Gtk.Button.with_label (_("Resume last game"));
                    button.clicked.connect (() => {
                        info_bar.no_show_all = true;
                        info_bar.hide ();
                        toolbar.set_board (sudoku_board);
                        set_board (sudoku_board);
                    });
                    infobox.pack_end (button);
                } else {
                    sudoku_board = null;
                }
                
            }
            welcome.activated.connect ((index) => {
                info_bar.no_show_all = true;
                info_bar.hide ();
                var choosenDifficulty = Difficulty.all ()[index];
                sudoku_board = new SudokuBoard (choosenDifficulty);
                toolbar.set_board (sudoku_board);
                set_board (sudoku_board);
            });
            show_all ();

        }

        private void set_board (SudokuBoard sudoku_board) {
            var board = new Board (sudoku_board);
            stack.add_named (board, "board");
            show_all ();
            stack.set_visible_child (board);
            sudoku_board.start ();
            sudoku_board.won.connect ((b) => {
                if (b.fails <= 3) {
                    settings.highscore = b.points;
                }
                win_page.set_board (b, settings.highscore);
                stack.set_visible_child (win_page);
                sudoku_board = null;
                settings.delete ();
            });
        }

        private bool on_window_closing () {
            if (sudoku_board != null) {
                settings.save (sudoku_board.to_string ());
            }
            return false;
        }
    }


}