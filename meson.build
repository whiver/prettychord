project('prettychord', ['c', 'vala'],
  version: '0.0.0-dev',
  meson_version: '>= 0.59.0',
)

i18n = import('i18n')
gnome = import('gnome')

add_project_arguments([
  '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
], language: 'c')

app_version = get_option('app_version')
if app_version == ''
  app_version = meson.project_version()
endif

conf = configuration_data()
conf.set('VERSION', app_version)

configure_file(
  input: 'src/Config.vala.in',
  output: 'Config.vala',
  configuration: conf
)

subdir('data')
subdir('po')
subdir('src')
