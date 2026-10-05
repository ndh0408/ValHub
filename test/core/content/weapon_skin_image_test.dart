import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/content/models/weapon_models.dart';

const _parent =
    'https://media.valorant-api.com/weaponskins/2a049f35-4bcd-af25-21fd-ec942e2d5007/displayicon.png';
const _level =
    'https://media.valorant-api.com/weaponskinlevels/9336ab9d-445c-0872-a283-9f9b61a0098a/displayicon.png';

WeaponSkin skin({
  String? parent,
  String? level,
  String? render,
  String? chroma,
}) => WeaponSkin.fromJson({
  'uuid': '2a049f35-4bcd-af25-21fd-ec942e2d5007',
  'displayName': 'Prime Guardian',
  'displayIcon': parent,
  'levels': [
    {
      'uuid': '9336ab9d-445c-0872-a283-9f9b61a0098a',
      'displayName': 'Prime Guardian',
      'displayIcon': level,
    },
  ],
  'chromas': [
    {
      'uuid': 'e2f5a979-4e9a-f931-7f52-d99f0ec4a61b',
      'displayName': 'Prime Guardian',
      'fullRender': render,
      'displayIcon': chroma,
    },
  ],
}, '4ade7faa-4cf1-8376-95ef-39884480959b')!;

void main() {
  test('Prime Guardian uses level art rather than the parent CDN X', () {
    // Public metadata observed 2026-10-05: parent URL returns HTTP 200 with
    // a 512x512 X; level URL returns the actual 512x104 Guardian artwork.
    final value = skin(parent: _parent, level: _level);
    expect(value.image, _level);
    expect(value.level1Uuid, '9336ab9d-445c-0872-a283-9f9b61a0098a');
  });

  test('missing level art retains the parent icon fallback', () {
    expect(skin(parent: _parent).image, _parent);
  });

  test('missing icons retain base chroma render and then chroma icon', () {
    expect(skin(render: 'render', chroma: 'chroma').image, 'render');
    expect(skin(chroma: 'chroma').image, 'chroma');
    expect(skin().image, isNull);
  });

  test('large render still prefers the base chroma', () {
    final value = skin(parent: _parent, level: _level, render: 'render');
    expect(value.render, 'render');
  });
}
