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
    public const string saveFile = "savegame";
    public const string highscoreFile = "highscore";

    public class SudokuSettings : Object {
        private File dataFolder;
        private int _highscore = 0;
        public int highscore {
            get { return _highscore; }
            set
            {
                if (value > _highscore) {
                    _highscore = value;
                    save_file (highscoreFile, "%i".printf (_highscore));
                }
            }
        }

        construct {
            try {
                dataFolder = File.new_for_path (Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_data_dir (), "com.github.parnold-x.sudoku"));
                if (!dataFolder.query_exists ()) {
                    dataFolder.make_directory ();
                }
                if (!isSaved_file (saveFile)) {
                     dataFolder.get_child (saveFile).create (FileCreateFlags.NONE);
                }
                if (isSaved_file (highscoreFile)) {
                    _highscore = int.parse (load_file (highscoreFile));
                }
            } catch (Error e) {
                error (e.message);
            }
        }

        public bool isSaved () {
            return isSaved_file (saveFile);
        }

        public bool isSaved_file (string file) {
            return dataFolder.get_child (file).query_exists ();
        }

        public string? load () {
            return load_file (saveFile);
        }

        public string? load_file (string file) {
            try {
                var dis = new DataInputStream (dataFolder.get_child (file).read ());
                return dis.read_line ();
            } catch (Error e) {
                error (e.message);
            }
        }

        public void save (string data) {
            save_file (saveFile, data);
        }

        public void save_file (string file_name, string data) {
            try {
                var file = dataFolder.get_child (file_name);
                if (file.query_exists ()) {
                    file.delete ();
                }
                var dos = new DataOutputStream (file.create (FileCreateFlags.REPLACE_DESTINATION));

                dos.put_string (data);
            } catch (Error e) {
                error (e.message);
            }
        }

        public void delete () {
            var file = dataFolder.get_child (saveFile);
            if (file.query_exists ()) {
                try {
                    file.delete ();
                } catch (Error e) {
                    error (e.message);
                }
            }
        }
    }
}