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
public enum Difficulty {
    EASY,
    MEDIUM,
    HARD,
    EXPERT;

    public string to_string () {
        switch (this) {
            case EASY:
                return "simple";
            case MEDIUM:
                return "easy";
            case HARD:
                return "intermediate";
            case EXPERT:
                return "expert";
            default:
                assert_not_reached ();
        }
    }

    public string to_translated_string () {
        switch (this) {
            case EASY:
                return _("Easy");
            case MEDIUM:
                return _("Medium");
            case HARD:
                return _("Hard");
            case EXPERT:
                return _("Master");
            default:
                assert_not_reached ();
        }
    }

    public static Difficulty from_string (string input) {
        switch (input) {
            case "simple":
                return EASY;
            case "easy":
                return MEDIUM;
            case "intermediate":
                return HARD;
            case "expert":
                return EXPERT;
            default:
                warning ("Could not parse difficulty level. Falling back to Easy difficulty");
                return EASY;
        }
    }

    public static Difficulty[] all() {
       return { EASY, MEDIUM, HARD, EXPERT };
    }
}
}