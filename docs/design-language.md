# 데스크톱 디자인 언어

색은 Catppuccin Mocha를 그대로 쓰고, 그 위에 유리 질감만 얹는다.
저장소 전체가 `catppuccin.flavor = "mocha"`, `catppuccin.accent = "mauve"`를 쓰고, Noctalia도 내장 `Catppuccin` 팔레트를 다크 모드로 고정해서 같은 색을 쓴다.
팔레트를 따로 정의하지 않기 때문에 새 앱은 `catppuccin/nix` 모듈이나 Noctalia 템플릿으로 테마한다.
UI 글꼴은 Pretendard다.

## 유리 질감의 원칙

1. 유리 질감은 블러, 채도 증폭(vibrancy), 1px 테두리, 부드러운 그림자로 낸다.
2. 셸 표면의 radius는 16, 창의 radius는 12다. 바깥 표면이 안쪽보다 더 둥글다.
3. 셸 표면은 반투명하게 두어 배경화면의 색이 블러를 거쳐 비치게 한다.

niri와 Noctalia로는 굴절이나 렌즈 왜곡, 가장자리 그라데이션 하이라이트를 만들 수 없다.
"liquid glass"는 위 요소로만 근사한다.
유리 질감은 색과 독립적이어서 팔레트를 바꿔도 다시 손볼 필요가 없다.

## 구현 위치

[Noctalia 모듈](../modules/home/noctalia/default.nix)의 `programs.noctalia.settings`:

| 역할 | 키와 값 |
|---|---|
| 색 | `theme.mode = "dark"`, `theme.source = "builtin"`, `theme.builtin = "Catppuccin"` |
| 앱으로 전달 | `theme.templates.builtin_ids`: GTK3, GTK4, Qt; `theme.templates.user.niri_palette`: niri. Ghostty는 공용 모듈의 `theme = Catppuccin Mocha`를 쓴다 |
| UI 글꼴 | `shell.font_family`: 공통 appearance의 Pretendard |
| 바 radius | `bar.main.radius = 16`; 네 모서리는 이 값을 상속한다 |
| 바 테두리 | `bar.main.border = "outline_variant"`, `bar.main.border_width = 1.0` |
| 바 투명도 | `bar.main.background_opacity = 0.40` |
| 알림 / OSD 투명도 | `notification.background_opacity = 0.70`, `osd.background_opacity = 0.70` |
| 그림자 | `shell.shadow.alpha = 0.30` |
| 패널 / 팝업 radius | `shell.corner_radius_scale = 1.25` |
| 유리 패널 | `shell.panel.transparency_mode = "glass"`; 카드 / 팝업 / 입력 테두리와 패널 1px 테두리는 기본값을 쓴다 |
| 배경화면 | `wallpaper.default.path`: [desktop-wallpaper.nix](../lib/desktop-wallpaper.nix)가 Pexels 사진 8417258을 `fetchurl`로 고정한다 |

[niri 모듈](../modules/home/niri/default.nix)의 `niriConfig`:

| 역할 | KDL 키와 값 |
|---|---|
| 부드럽고 넓은 블러 | `blur.passes = 4`, `blur.offset = 4` |
| 매끈한 표면 | `blur.noise = 0.015` |
| 배경색의 채도 증폭 | `blur.saturation = 1.8` |
| 창 radius / 클리핑 | `window-rule`: `geometry-corner-radius 12`, `clip-to-geometry true` |
| Noctalia 블러 영역 | `layer-rule`의 `background-effect { xray false; }`; 영역은 셸이 제공한다 |
| Ghostty 창 블러 | Ghostty `window-rule`의 `background-effect { blur true; }` |

블러 키는 [niri 문서](https://github.com/niri-wm/niri/wiki/Configuration:-Miscellaneous#blur)를 따른다.

그리터는 [NixOS Noctalia 모듈](../modules/nixos/noctalia.nix)이 `services.displayManager.noctalia-greeter.settings.appearance.wallpaper.path`에 같은 사진을 지정한다.
이 값은 `greeter.toml`에 들어가고, 셸의 appearance sync는 이 파일을 쓰지 않는다.

## Nix가 유일한 기준

Noctalia는 설정 UI와 IPC로 바꾼 값을 `~/.local/state/noctalia/settings.toml`에 쓰고, 이 파일을 `config.toml`보다 우선한다.
그래서 Noctalia 서비스는 시작할 때마다 이 파일을 지운다(`ExecStartPre`).
설정 UI에서 바꾼 값은 다음 재시작 전까지만 유지된다.
계속 쓸 값은 Nix 설정으로 옮긴다.

## 튜닝

`shell.corner_radius_scale = 1.25`와 각 투명도 값은 화면을 보며 맞춘 값이다.
값을 바꾸면 스크린샷으로 radius, 블러, 그림자, 텍스트 가독성을 확인한다.
