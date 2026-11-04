# 데스크톱 디자인 언어

niri와 Noctalia 데스크톱은 중립 모노 표면과 glacier blue 강조색 하나를 사용한다.
다크 모드로 고정하며 UI 글꼴은 Pretendard를 유지한다. 팔레트 식별자는 `desktop`이다.
새 앱을 테마할 때는 아래 토큰을 기준으로 하고, 가능하면 Noctalia 템플릿으로 전달한다.

## 디자인 원칙

1. 표면은 무채색이다. 색은 강조색 한 곳에만 쓴다.
2. 위계는 색이 아니라 밝기와 투명도로 표현한다. hover와 선택도 중립 회색이다.
3. 유리 질감은 블러, 채도 증폭(vibrancy), 밝은 1px 테두리, 부드러운 그림자로 낸다.
4. 셸 표면의 radius는 16, 창의 radius는 기존 12다. 바깥 표면이 안쪽보다 더 둥글다.

niri와 Noctalia로는 굴절이나 렌즈 왜곡, 가장자리 그라데이션 하이라이트를 만들 수 없다. "liquid glass"는 위 네 요소로만 근사한다.

## 토큰

| 역할 | 값 | 의도 |
|---|---|---|
| `surface` | `#1C1C1E` | 기본 표면. 순흑이 아닌 아주 약간 차가운 회색 |
| `surface_container` | `#262628` | 카드, 입력칸 |
| `outline_variant` | `#404044` | 1px 테두리. 유리 가장자리 하이라이트 역할이라 일반 구분선보다 밝다 |
| `hover` / `on_hover` | `#34343A` / `#F2F2F2` | 중립 hover |
| `on_surface` | `#F2F2F2` | 본문 텍스트 |
| `on_surface_variant` | `#9C9CA3` | 보조 텍스트 |
| `primary` / `on_primary` | `#8CB8FF` / `#0E1A2B` | 강조색 glacier blue. 유리와 빛을 떠올리는 차갑고 옅은 파랑 |
| `secondary` / `on_secondary` | `#C7C7CC` / `#1C1C1E` | 중립 보조 |
| `tertiary` / `on_tertiary` | `#A9C1E8` / `#1C1C1E` | 강조색의 저채도 형제 |
| `error` / `on_error` | `#FF8A80` / `#2B0F0D` | 오류 |
| `shadow` | `#000000` | |

터미널 ANSI:

| | black | red | green | yellow | blue | magenta | cyan | white |
|---|---|---|---|---|---|---|---|---|
| normal | `#2C2C2E` | `#E5737A` | `#8CCB8C` | `#E3C27A` | `#8CB8FF` | `#C5A3F0` | `#7FCFD6` | `#D1D1D6` |
| bright | `#48484C` | `#FF8A8F` | `#A6E0A6` | `#F2D594` | `#A9CBFF` | `#D7BCF7` | `#9DE0E6` | `#F2F2F7` |

그 외 터미널 값: `background #1C1C1E`, `foreground #E6E6E8`, `cursor #8CB8FF`, `cursor_text #1C1C1E`, `selection_bg #3A4A66`, `selection_fg #F2F2F2`.

## 구현 위치

팔레트의 원본은 [palette.json](../modules/home/noctalia/palette.json)이다.
[Noctalia 팔레트 형식](https://docs.noctalia.dev/noctalia/theming/palette/)의 version 2를 사용하며
`dark` 블록만 둔다. 아래 색상 키는 모두 이 파일의 `dark` 아래에 있다.

| 토큰 | 파일과 키 |
|---|---|
| 기본 표면 / 카드 | `palette.json`: `dark.surface`, `dark.surface_container` |
| 테두리 | `palette.json`: `dark.outline_variant` |
| hover / hover 텍스트 | `palette.json`: `dark.hover`, `dark.on_hover` |
| 본문 / 보조 텍스트 | `palette.json`: `dark.on_surface`, `dark.on_surface_variant` |
| 강조색 / 강조색 위 텍스트 | `palette.json`: `dark.primary`, `dark.on_primary` |
| 중립 보조 / 보조색 위 텍스트 | `palette.json`: `dark.secondary`, `dark.on_secondary` |
| 저채도 강조 / 그 위 텍스트 | `palette.json`: `dark.tertiary`, `dark.on_tertiary` |
| 오류 / 오류색 위 텍스트 | `palette.json`: `dark.error`, `dark.on_error` |
| 그림자 색 | `palette.json`: `dark.shadow` |
| 터미널 기본색 / 커서 / 선택 | `palette.json`: `dark.terminal.background`, `foreground`, `cursor`, `cursor_text`, `selection_bg`, `selection_fg` |
| ANSI normal / bright | `palette.json`: `dark.terminal.normal.<color>`, `dark.terminal.bright.<color>` |

[Noctalia 모듈](../modules/home/noctalia/default.nix)의 설정 키는 아래와 같다.
`programs.noctalia.settings` 아래의 키로 표기한다.

| 역할 | 키와 값 |
|---|---|
| 팔레트 설치 | `xdg.configFile."noctalia/palettes/desktop.json".source = ./palette.json` (모듈 최상위) |
| 다크 고정 / 팔레트 선택 | `theme.mode = "dark"`, `theme.source = "custom"`, `theme.custom_palette = "desktop"` |
| 앱으로 전달 | `theme.templates.builtin_ids`: GTK3, GTK4, Qt, Ghostty; `theme.templates.user.niri_palette`: niri |
| UI 글꼴 | `shell.font_family`: 공통 appearance의 Pretendard |
| 바 radius | `bar.main.radius = 16`; 네 모서리는 이 값을 상속한다 |
| 바 테두리 | `bar.main.border = "outline_variant"`, `bar.main.border_width = 1.0` |
| 바 투명도 | `bar.main.background_opacity = 0.40` |
| 알림 / OSD 투명도 | `notification.background_opacity = 0.70`, `osd.background_opacity = 0.70` |
| 그림자 | `shell.shadow.alpha = 0.30` |
| 패널 / 팝업 radius | `shell.corner_radius_scale = 1.25` |
| 유리 패널 | `shell.panel.transparency_mode = "glass"`; 카드 / 팝업 / 입력 테두리와 패널 1px 테두리는 기본값 사용 |

[niri 모듈](../modules/home/niri/default.nix)의 `niriConfig`가 전역 블러를 선언한다.
[상위 niri 문서](https://github.com/niri-wm/niri/wiki/Configuration:-Miscellaneous#blur)의 키를 사용한다.

| 역할 | KDL 키와 값 |
|---|---|
| 부드럽고 넓은 블러 | `blur.passes = 4`, `blur.offset = 4` |
| 매끈한 표면 | `blur.noise = 0.015` |
| 배경색의 채도 증폭 | `blur.saturation = 1.8` |
| 창 radius / 클리핑 | `window-rule`: `geometry-corner-radius 12`, `clip-to-geometry true` |
| Noctalia 블러 영역 | 기존 `layer-rule`의 `background-effect { xray false; }`; 영역은 셸이 제공한다 |
| Ghostty 창 블러 | 기존 Ghostty `window-rule`의 `background-effect { blur true; }` |

## 검증과 튜닝

WCAG 상대 휘도로 계산한 불투명 토큰 대비는 본문/표면 15.20:1,
보조 텍스트/표면 6.24:1, 강조색 위 텍스트/강조색 8.67:1이다.
모두 4.5:1 이상이며, 토큰 값은 원안 그대로다. 실제 반투명 표면의 가독성은 배경에 따라 달라진다.

`shell.corner_radius_scale = 1.25`는 패널과 팝업을 바의 16px 근처로 맞추려는 튜닝 지점이다.
설정을 적용한 뒤 실제 화면에서 radius, 블러, 그림자, 투명도와 텍스트 가독성을 확인한다.
배경화면은 현재 것을 유지한다. Zed와 기존 `catppuccin.*` 설정은 이 팔레트의 적용 범위 밖이다.
