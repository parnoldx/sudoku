project('com.github.parnold-x.sudoku', ['vala', 'c'],
    version: '0.1.4'
)

gnome = import('gnome')

asresources = gnome.compile_resources(
    'as-resources', 'data/img.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)


conf = configuration_data()
# Get the package data directory under Meson
pkgdatadir = join_paths([ get_option('prefix'),
                          get_option('datadir'),
                          meson.project_name() ])

conf.set_quoted('PKGDATADIR', pkgdatadir)

# Other configs
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf
add_global_arguments('-DDATADIR="' + get_option('datadir') + '"', language: 'c')
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

# Arguments for C
c_args = [
  '-include', 'config.h',
  '-w'
]

executable(
    'com.github.parnold-x.sudoku',
    'src/Application.vala',
    'src/MainWindow.vala',
    'src/Board.vala',
    'src/ToolBar.vala',
    'src/WinPage.vala',
    'src/logic/Difficulty.vala',
    'src/logic/SudokuBoard.vala',
    'src/logic/SudokuSettings.vala',
    asresources,
    c_args: c_args,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gio-2.0'),
        dependency('gio-unix-2.0'),
        dependency('gobject-2.0'),
        dependency('gtk+-3.0'),
        dependency('granite')
    ],
    install : true
)

subdir('data')
#subdir('po')
