project('com.github.parnold-x.sudoku', ['vala', 'c'],
    version: '0.2.0'
)

gnome = import('gnome')
i18n = import('i18n')

asresources = gnome.compile_resources(
    'as-resources', 'data/img.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')], language: 'vala')

conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

c_args = [
  '-include', 'config.h',
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