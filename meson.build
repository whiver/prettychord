project('prettychord', ['c', 'vala'],
  version: '0.1.0',
  meson_version: '>= 0.59.0',
)

i18n = import('i18n')
gnome = import('gnome')

add_project_arguments([
  '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
], language: 'c')

subdir('data')
subdir('src')
