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

    public class SudokuBoard : Object {
        private const int time_factor_reduce = 34; // s
        private const double points_block_row = 11.25;
        public Difficulty difficulty { get; private set; }
        public int[,] board;
        public int[,] solution;
        public int points { get; private set; }
        public int factor { get; private set; }
        public int time  { get; private set; } //s
        public int fails { get; private set; }
        public signal void highlight (int row, int col);
        public signal void won (SudokuBoard board);


        public SudokuBoard (Difficulty difficulty) {
            try {
                Pid pid;
                int read_fd, write_fd;
                string[] argv = {"qqwing", "--generate", "--solution","--one-line", "--difficulty", difficulty.to_string()};

                Process.spawn_async_with_pipes (null, argv, null,
                    SpawnFlags.SEARCH_PATH,
                    null, out pid, out write_fd, out read_fd);

                UnixInputStream read_stream = new UnixInputStream (read_fd, true);
                DataInputStream bc_output = new DataInputStream (read_stream);
                var dataStr = difficulty.to_string ();
                dataStr+="|";
                dataStr+= bc_output.read_line ();
                dataStr+="|";
                dataStr+= bc_output.read_line ();
                dataStr+="|";
                if (difficulty == Difficulty.EASY) {
                    dataStr+="28"; //factor
                } else if (difficulty == Difficulty.MEDIUM) {
                    dataStr+="56"; //factor
                } else if (difficulty == Difficulty.HARD) {
                    dataStr+="112"; //factor
                } else if (difficulty == Difficulty.EXPERT) {
                    dataStr+="156"; //factor
                }
                dataStr+="|";
                dataStr+="0"; // points
                dataStr+="|";
                dataStr+="0"; // time
                dataStr+="|";
                dataStr+="0"; // fails
                this.from_string (dataStr);
            } catch (Error err) {
                error ("%s", err.message);
            }
        }

        uint timer;
        public void start () {
            timer = GLib.Timeout.add (1000, () => {
                time+=1;
                if (time % time_factor_reduce == 0 && factor > 1) {
                    factor--;
                }
                return true;
            });
        }

        public void pause () {
            GLib.Source.remove (timer);
        }

        public void fail () {
            fails++;
        }

        public void scored (int row, int col) {
            points += board[row, col]*factor;
            highlight (row, col);
            bool colScore = true;
            for (var rowI = 0; rowI < 9; rowI++) {
                if (board[rowI,col] == 0) {
                    colScore = false;
                    break;
                }
            }
            if (colScore) {
                points += (int) points_block_row*factor;
                for (var rowI = 0; rowI < 9; rowI++) {
                    highlight (rowI, col);
                }
            }
            bool rowScore = true;
            for (var colI = 0; colI < 9; colI++) {
                if (board[row,colI] == 0) {
                   rowScore = false;
                   break;
                }
            }
            if (rowScore) {
                points += (int) points_block_row*factor;
                for (var colI = 0; colI < 9; colI++) {
                    highlight (row, colI);
                }
            }
            for (int rowI = row - row % 3; rowI < row - row % 3 + 3; rowI++) {
                for (int colI = col - col % 3; colI < col - col % 3 + 3; colI++) {
                    if (board[rowI,colI] == 0) {
                        return;
                    }
                }
            }
            points += (int) points_block_row*factor;
            for (int rowI = row - row % 3; rowI < row - row % 3 + 3; rowI++) {
                for (int colI = col - col % 3; colI < col - col % 3 + 3; colI++) {
                    highlight (rowI, colI);
                }
            }
            if (!isFinshed ()) {
                return;
            }
            for (int rowI = 0; rowI < 9; rowI++) {
                for (int colI = 0; colI < 9; colI++) {
                    highlight (rowI, colI);
                }
            }
            GLib.Timeout.add (2000, () => {
                won (this);
                return false;
            });
        }

        public bool isFinshed () {
            for (int rowI = 0; rowI < 9; rowI++) {
                for (int colI = 0; colI < 9; colI++) {
                    if (board[rowI,colI]!=solution[rowI,colI]) {
                        return false;
                    }
                }
            }
            return true;
        }

        public SudokuBoard.from_string (string data) {
            var splitData = data.split ("|");
            this.difficulty = Difficulty.from_string (splitData[0]);
            board = new int[9,9];
            solution = new int[9,9];
            for (int row = 0; row < 9; row++) {
                for (int cols = 0; cols < 9; cols++) {
                    var sign = splitData[1].get_char (row*9+cols);
                    if (sign == '.'){
                        board[row,cols] = 0;
                    } else {
                        board[row,cols] = int.parse(sign.to_string ());
                    }
                }
            }
            for (int row = 0; row < 9; row++) {
                for (int cols = 0; cols < 9; cols++) {
                    var sign = splitData[2].get_char (row*9+cols);
                    solution[row,cols] = int.parse(sign.to_string ());
                }
            }
            factor = int.parse (splitData[3]);
            points = int.parse (splitData[4]);
            time = int.parse (splitData[5]);
            fails = int.parse (splitData[6]);
        }

        public string to_string() {
            var dataStr = difficulty.to_string ();
            dataStr+="|";
            for (int row = 0; row < 9; row++) {
                for (int cols = 0; cols < 9; cols++) {
                    var val = board[row,cols];
                    if (val == 0) {
                        dataStr+=".";
                    } else {
                        dataStr+= "%i".printf(board[row,cols]);
                    }
                }
            }
            dataStr+="|";
            for (int row = 0; row < 9; row++) {
                for (int cols = 0; cols < 9; cols++) {
                    dataStr+= "%i".printf(solution[row,cols]);
                }
            }
            dataStr+="|";
            dataStr+="%i".printf(factor);
            dataStr+="|";
            dataStr+="%i".printf(points);
            dataStr+="|";
            dataStr+="%i".printf(time);
            dataStr+="|";
            dataStr+="%i".printf(fails);
            return dataStr;
        }
    }
}