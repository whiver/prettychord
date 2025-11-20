deps = [
  dependency('gtk4'),
  dependency('gee-0.8'),
  dependency('cairo'),
]

sources = files(
  'main.vala',
  'Application.vala',
  'Window.vala',
  'ChordParser.vala',
  'ChordRenderer.vala',
)

executable('prettychord', sources,
  dependencies: deps,
  install: true,
)
