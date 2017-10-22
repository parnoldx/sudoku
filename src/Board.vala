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
	private class Cell : Gtk.DrawingArea {
		public int row;
		public int col;
		private SudokuBoard board;
		private double zoomFactor = 1;
		public bool green_highlight = false;
		public bool red_highlight = false;
		public bool red_highlight_secondary = false;
		public signal void cell_clicked (int row, int col, bool right_click);
		public signal void number_entered (int row, int col, int number, bool ctrl);

		public Cell (int row, int col, SudokuBoard board) {
			this.row = row;
			this.col = col;
			this.board = board;

			can_focus = true;
        	events = Gdk.EventMask.EXPOSURE_MASK | Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK | Gdk.EventMask.KEY_PRESS_MASK;
		}

		public void deselect () {
			green_highlight = false;
			red_highlight = false;
			red_highlight_secondary = false;
		}

		public void zoom () {
			var factor = 0.05;
			GLib.Timeout.add (30,() => {
				zoomFactor += factor;
				queue_draw ();
				if (zoomFactor <= 1) {
					zoomFactor = 1;
					queue_draw ();
					return false;
				} else if (zoomFactor >= 1.6) {
					factor = -0.05;
				}
				return true;
			});
		}


		public override bool button_press_event (Gdk.EventButton event) {
        	if (event.button != 1 && event.button != 3)
            	return false;

           	grab_focus ();

        	cell_clicked (row, col, event.button == 3);
        	return false;
    	}

    	public override bool key_press_event (Gdk.EventKey event) {
    		string k_name = Gdk.keyval_name (event.keyval);
        	int k_no = int.parse (k_name);
        	/* If k_no is 0, there might be some error in parsing, crosscheck with keypad values. */
        	if (k_no == 0)
        	    k_no = key_map_keypad (k_name);
        	if (k_no >= 1 && k_no <= 9) {
        		number_entered (row, col, k_no, (event.state & Gdk.ModifierType.CONTROL_MASK) > 0);
        	}
        	// arrow navigation
        	if (k_name == "Right" && col < 8) {
        		cell_clicked (row, col + 1, false);
        	} else if (k_name == "Left" && col > 0) {
        		cell_clicked (row, col -1, false);
        	} else if (k_name == "Up" && row > 0) {
        		cell_clicked (row - 1, col, false);
        	} else if (k_name == "Down" && row < 8) {
        		cell_clicked (row + 1, col, false);
        	}
        	return false;
    	}

    	private int key_map_keypad (string key_name) {
    		// also enable yxcasdqwe as "left hand keypad"
        	if (key_name == "KP_0" || key_name == "0")
        	    return 0;
        	if (key_name == "KP_1" || key_name == "y")
        	    return 1;
        	if (key_name == "KP_2" || key_name == "x")
        	    return 2;
        	if (key_name == "KP_3" || key_name == "c")
        	    return 3;
        	if (key_name == "KP_4" || key_name == "a")
        	    return 4;
        	if (key_name == "KP_5" || key_name == "s")
        	    return 5;
        	if (key_name == "KP_6" || key_name == "d")
        	    return 6;
        	if (key_name == "KP_7" || key_name == "q")
        	    return 7;
        	if (key_name == "KP_8" || key_name == "w")
        	    return 8;
        	if (key_name == "KP_9" || key_name == "e")
        	    return 9;
        	return -1;
    	}

		public override bool draw (Cairo.Context c) {
			var value = board.board[row,col];
			if (value != 0) {
            	c.save ();
				string drawtext = "%i".printf(value);
				Cairo.TextExtents extents;
     			c.set_font_size((get_allocated_height () / 1.5) * zoomFactor);
            	c.text_extents (drawtext, out extents);
            	c.move_to ((get_allocated_width () - extents.width) / 2 - 1, (get_allocated_height () + extents.height) / 2 + 1);
            	c.set_source_rgb (0.365, 0.082, 0.098);
            	c.show_text (drawtext);
				c.restore ();
			}
			int xdelta = 0;
			int ydelta = 0;
			if (green_highlight) {
				// green highlight
				c.set_line_width (6);
				c.set_source_rgba (0.4039, 0.6392, 0.3882, 0.4);
				roundedrec (c, xdelta, ydelta, get_allocated_width () - xdelta, get_allocated_height () - ydelta, 10);
				c.stroke ();
				c.set_line_width (3);
				c.set_source_rgba (0.1294, 0.4902, 0.2431, 0.9);
				roundedrec (c, xdelta, ydelta, get_allocated_width () - xdelta, get_allocated_height () - ydelta, 10);
				c.stroke ();
				xdelta += 1;
				ydelta += 1;
				c.set_line_width (2);
				c.set_source_rgba (0.0706, 0.9333, 0.1059, 1);
				roundedrec (c, xdelta, ydelta, get_allocated_width () - xdelta, get_allocated_height () - ydelta, 10);
				c.stroke ();
			}
			if (red_highlight) {
				// red highlight
				c.set_line_width (6);
				c.set_source_rgba (0.8549, 0.1412, 0.1294, 0.4);
				roundedrec (c, xdelta, ydelta, get_allocated_width () - xdelta, get_allocated_height () - ydelta, 10);
				c.stroke ();
				c.set_line_width (3);
				c.set_source_rgba (0.8549, 0.1412, 0.1294, 0.9);
				roundedrec (c, xdelta, ydelta, get_allocated_width () - xdelta, get_allocated_height () - ydelta, 10);
				c.stroke ();
				xdelta += 1;
				ydelta += 1;
				c.set_line_width (2);
				c.set_source_rgba (0.9843, 0.4352, 0.4392, 1);
				roundedrec (c, xdelta, ydelta, get_allocated_width () - xdelta, get_allocated_height () - ydelta, 10);
				c.stroke ();
			}
			if (red_highlight_secondary) {
				// red second highlight
				c.set_line_width (6);
				c.set_source_rgba (0.8549, 0.1412, 0.1294, 0.2);
				roundedrec (c, xdelta, ydelta, get_allocated_width (), get_allocated_height (), 10);
				c.stroke ();
				xdelta += 1;
				ydelta += 1;
				c.set_line_width (2);
				c.set_source_rgba (0.9608, 0.7843, 0.6941, 0.4);
				roundedrec (c, xdelta, ydelta, get_allocated_width () - xdelta, get_allocated_height () - ydelta, 10);
				c.stroke ();
			}
            return true;
		}
		private void roundedrec (Cairo.Context cr, int x, int y, int width, int height, int radius = 5, bool fill = false) {
        	int x0 = x + radius / 2;
        	int y0 = y + radius / 2;
        	int rect_width = width - radius;
        	int rect_height = height - radius;

	        cr.save ();

	        int x1 = x0 + rect_width;
	        int y1 = y0 + rect_height;

	        if (rect_width / 2 < radius) {
	            if (rect_height / 2 < radius) {
	                cr.move_to (x0, (y0 + y1) / 2);
	                cr.curve_to (x0, y0, x0, y0, (x0 + x1) / 2, y0);
	                cr.curve_to (x1, y0, x1, y0, x1, (y0 + y1) / 2);
	                cr.curve_to (x1, y1, x1, y1, (x1 + x0) / 2, y1);
	                cr.curve_to (x0, y1, x0, y1, x0, (y0 + y1) / 2);
	            } else {
	                cr.move_to (x0, y0 + radius);
	                cr.curve_to (x0, y0, x0, y0, (x0 + x1) / 2, y0);
	                cr.curve_to (x1, y0, x1, y0, x1, y0 + radius);
	                cr.line_to (x1, y1 - radius);
	                cr.curve_to (x1, y1, x1, y1, (x1 + x0) / 2, y1);
	                cr.curve_to (x0, y1, x0, y1, x0, y1 - radius);
	            }
	        } else {
	            if (rect_height / 2 < radius) {
	                cr.move_to (x0, (y0 + y1) / 2);
	                cr.curve_to (x0, y0, x0, y0, x0 + radius, y0);
	                cr.line_to (x1 - radius, y0);
	                cr.curve_to (x1, y0, x1, y0, x1, (y0 + y1) / 2);
	                cr.curve_to (x1, y1, x1, y1, x1 - radius, y1);
	                cr.line_to (x0 + radius, y1);
	                cr.curve_to (x0, y1, x0, y1, x0, (y0 + y1) / 2);
	            } else {
	                cr.move_to (x0, y0 + radius);
	                cr.curve_to (x0, y0, x0, y0, x0 + radius, y0);
	                cr.line_to (x1 - radius, y0);
	                cr.curve_to (x1, y0, x1, y0, x1, y0 + radius);
	                cr.line_to (x1, y1 - radius);
	                cr.curve_to (x1, y1, x1, y1, x1 - radius, y1);
	                cr.line_to (x0 + radius, y1);
	                cr.curve_to (x0, y1, x0, y1, x0, y1 - radius);
	            }
	        }

	        cr.close_path ();

	        if (fill) {
	            cr.fill ();
	        }

        	cr.restore ();
    	}
	}

	public class Board : Gtk.AspectFrame {

    	private Gtk.Overlay overlay;
    	private Gtk.DrawingArea drawing;
    	private Gtk.Grid grid;
    	private SudokuBoard board;
    	private string drawtext;
    	private double text_animation_factor;

		public Board (SudokuBoard board) {
			this.board = board;
            this.get_style_context ().add_class ("sudoku-board");
			shadow_type = Gtk.ShadowType.NONE;
        	obey_child = false;
        	ratio = 1;

        	overlay = new Gtk.Overlay ();
        	add (overlay);

        	drawing = new Gtk.DrawingArea ();
        	drawing.draw.connect (draw_board);

        	grid = new Gtk.Grid ();
        	grid.row_spacing = 1;
        	grid.column_spacing = 1;
        	grid.column_homogeneous = true;
        	grid.row_homogeneous = true;
        	for (var row = 0; row < 9; row++) {
            	for (var col = 0; col < 9; col++) {
            		var cell = new Cell (row, col, board);
            		cell.cell_clicked.connect (cell_clicked);
            		cell.number_entered.connect (number_entered);
                	grid.attach (cell, col, row, 1, 1);
                	cell.zoom ();
            	}
            }
            overlay.add (drawing);
        	overlay.add_overlay (grid);
        	drawing.show ();
        	grid.show_all ();
        	overlay.show ();

        	board.highlight.connect ((r,c) => {
        		get_cell (r, c).zoom ();
        	});
        	board.notify["fails"].connect ((s, p) => {
        		drawtext = "Wrong number";
				text_animation_factor = 1;
				GLib.Timeout.add (30,() => {
					text_animation_factor += 0.05;
					queue_draw ();
					if (text_animation_factor >= 1.85) {
						text_animation_factor = -1;
						queue_draw ();
						return false;
					}
					return true;
				});
        	});
		}

		private void number_entered (int row, int col, int number, bool ctrl) {
			var value = board.board[row,col];
			if (value == 0) {
				var solution = board.solution[row,col];
				if (solution == number) {
					//successful
					board.board[row,col] = number;
					highlight (row, col);
					board.scored (row, col);
				} else {
					//fail
					board.fail ();
				}
			}
        	grid.queue_draw ();
		}

		private void cell_clicked (int row, int col, bool right_click) {
            if (!right_click) {           // Left-Click
            	highlight (row, col);
        	} else {         // Right-Click
        	}
        	grid.queue_draw ();
		}

		private void highlight (int row, int col) {
			deselect ();
			var value = board.board[row,col];
			if (value != 0) {
				for (var rowI = 0; rowI < 9; rowI++) {
            		for (var colI = 0; colI < 9; colI++) {
            			var cell = get_cell (rowI,colI);
            			if (board.board[cell.row,cell.col] == value) {
            				cell.green_highlight = true;
            			}
            		}
            	}
			} else {
				get_cell (row,col).red_highlight = true;
				for (var rowI = 0; rowI < 9; rowI++) {
					if (rowI == row) {
						continue;
					}
					if (board.board[rowI,col] != 0) {
						get_cell (rowI,col).red_highlight_secondary = true;
					}
				}
				for (var colI = 0; colI < 9; colI++) {
					if (colI == col) {
						continue;
					}
					if (board.board[row,colI] != 0) {
						get_cell (row,colI).red_highlight_secondary = true;
					}
				}
			}
		}

		private void deselect() {
        	for (var row = 0; row < 9; row++) {
            	for (var col = 0; col < 9; col++) {
					get_cell (row,col).deselect ();
            	}
            }
		}

		private Cell get_cell (int row, int col) {
			return grid.get_child_at (col,row) as Cell;
		}


		private bool draw_board (Cairo.Context c) {
        	int board_length = grid.get_allocated_width ();
        	/* not exactly the tile's edge length: includes the width of a border line (1) */
        	double tile_length = ((double) (board_length - 1)) / 9;

        	if (Gtk.Widget.get_default_direction () == Gtk.TextDirection.RTL) {
        	    c.translate (board_length, 0);
        	    c.scale (-1, 1);
        	}

        // /* TODO game.board.cols == game.board.rows... */
        // for (var i = 0; i < 9; i++) {
        //     for (var j = 0; j < 9; j++) {
        //         var background_color = cells[i, j].background_color;
        //         c.set_source_rgb (background_color.red, background_color.green, background_color.blue);

        //         c.rectangle ((int) (j * tile_length) + 0.5, (int) (i * tile_length) + 0.5, (int) ((j + 1) * tile_length) + 0.5, (int) ((i + 1) * tile_length) + 0.5);
        //         c.fill ();
        //     }
        // }

        	c.set_line_width (1);
        	c.set_source_rgb (0.6, 0.6, 0.6);
        	for (var i = 1; i < 9; i++) {
        	    if (i % 3 == 0)
        	        continue;
        	    /* we could use board_length - 1 */
        	    c.move_to (((int) (i * tile_length)) + 0.5, 1);
        	    c.line_to (((int) (i * tile_length)) + 0.5, board_length);
        	}
        	for (var i = 1; i < 9; i++) {
        	    if (i % 3 == 0)
        	        continue;

        	    c.move_to (1, ((int) (i * tile_length)) + 0.5);
        	    c.line_to (board_length, ((int) (i * tile_length)) + 0.5);
        	}
        	c.stroke ();

        	c.set_line_width (2);
        	c.set_source_rgb (0.0, 0.0, 0.0);
        	for (var i = 0; i <= 9; i += 3) {
        	    c.move_to (((int) (i * tile_length)) + 0.5, 0);
        	    c.line_to (((int) (i * tile_length)) + 0.5, board_length);
        	}
        	for (var i = 0; i <= 9; i += 3) {
        	    c.move_to (0, ((int) (i * tile_length)) + 0.5);
        	    c.line_to (board_length, ((int) (i * tile_length)) + 0.5);
        	}
        	c.stroke ();

        	if (text_animation_factor > 0) {
        		Cairo.TextExtents extents;
     			c.set_font_size(30 * text_animation_factor);
            	c.text_extents (drawtext, out extents);
				c.move_to ((get_allocated_width () / 2) - (extents.width / 1.34), get_allocated_height () / 2 - extents.height / 2);
            	c.set_source_rgb (1, 1, 1);
				c.show_text (drawtext);
        	}

        	return false;
    	}
	}
}