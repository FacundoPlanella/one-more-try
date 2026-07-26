# GAME DESIGN DOCUMENT
## One more try. — Casual Mobile Game

| Campo | Valor |
|-------|--------|
| **Versión del documento** | 1.1 |
| **Estado** | Aprobado — en desarrollo |
| **Plataformas** | Android + iOS |
| **Motor propuesto** | Flutter (Dart) |
| **Monetización** | Banner inferior permanente (AdMob) |
| **Modo** | 100% offline |
| **Equipo objetivo** | 1 desarrollador |

---

## 1. Nombre del juego

**One more try.**

### Por qué este nombre
- Es el loop emocional del juego: siempre apetece **una partida más**.
- Memorable, hablable y fácil de recordar tras una muerte.
- Funciona en inglés como marca global; el punto final le da identidad tipográfica.
- Encaja con la mecánica: **un toque**, **una vida**, **un intento más**.
- Branding visual: tipografía display + orbe minimalista.

**Tagline:** *One tap. One life. One more try.*

**Nombre técnico / package:**
- Android: `com.studio.onemoretry.game`
- iOS: `com.studio.onemoretry.game`
- Nombre interno de proyecto: `one_more_try`
- Nombre corto en launcher (si hay límite): `One more try`

---

## 2. Concepto

**One more try.** es un juego casual de supervivencia en carriles con una sola acción: **tocar para cambiar de carril**.

Un punto luminoso avanza automáticamente por un camino vertical infinito de **3 carriles**. Obstáculos se generan de forma procedural. El jugador sobrevive el mayor tiempo posible.

Es el arquetipo “one more try”:
- Partida en < 3 segundos.
- Muertes claras y justas.
- “Casi lo logro” constante.
- Sesiones de 30 s a 3 min.
- Progresión infinita sin niveles hechos a mano.

### Propuesta de valor
| Para el jugador | Para el negocio |
|-----------------|-----------------|
| Fácil de entender en 5 segundos | Desarrollo barato y rápido |
| Difícil de dominar | Mantenimiento mínimo |
| Adictivo y relajante a la vez | Solo banner (UX limpia) |
| Progreso offline real | Ingresos pasivos estables |
| Skins y misiones diarias | Retención sin servidores |

### Referencias de mercado (inspiración, no clones)
- Geometry Dash (feedback / ritmo) — simplificado a 1 input
- Crossy Road / Frogger — cambio de posición
- Stack / Helix — “una más”
- Color Switch — minimalismo y claridad

**Diferenciador:** estética calmada + dificultad justa + retención offline (skins, misiones, títulos) + cero friction de anuncios invasivos.

---

## 3. Mecánica principal

### Input
- **Un solo toque** en cualquier parte de la zona de juego.
- Cada toque cicla el carril: `Izquierda → Centro → Derecha → Izquierda…`
- Alternativa de accesibilidad (misma mecánica): toque en mitad izquierda = carril anterior; mitad derecha = carril siguiente.  
  **Decisión recomendada para v1:** ciclo simple con un toque (menor carga cognitiva, más viral).

### Avatar
- Círculo/orbe minimalista en el carril actual.
- Se mueve con interpolación suave (ease-out) al cambiar de carril (~120–160 ms).
- Trail sutil detrás del orbe.

### Mundo
- Scroll vertical infinito hacia abajo (o el orbe “sube” y el mundo baja — mismo efecto).
- 3 carriles fijos, anchos iguales.
- Obstáculos: bloques sólidos en 1 o 2 carriles.
- Coleccionables opcionales: **orbes de puntuación** (+1 / combo).

### Colisión
- Hitbox circular del jugador vs. rectángulos de obstáculos.
- Margen de perdón de 4–6 % del ancho del carril (sensación justa, no frustrante).
- Al colisionar: shake suave + flash + sonido corto → pantalla de resultado.

### Controles de ritmo
- El jugador **no** controla la velocidad.
- Solo controla la posición lateral.
- La velocidad aumenta con el score/tiempo (ver §7).

---

## 4. Loop de juego

```
[Splash <1.5s]
    → [Menú principal]
        → Tap "Play" (<0.5s)
            → [Partida]
                → Sobrevive / puntuación sube
                → Colisión
            → [Resultado]
                → ¿Nuevo récord? / logros / misión
                → "Otra vez" (1 tap)  ──┐
                → "Menú"                 │
                                         └──→ [Partida]
```

### Loop emocional (retención)
1. **Entrada inmediata** — sin tutorial largo (tutorial de 3 segundos la primera vez).
2. **Flow** — música suave + feedback visual.
3. **Casi** — muerte percibida como error propio, no del juego.
4. **Recompensa** — score, récord, progreso de skin/misión.
5. **Retry** — botón grande “Otra vez” sobre el área libre del banner.

### Duración objetivo por partida
| Nivel de habilidad | Duración aproximada |
|--------------------|---------------------|
| Principiante | 15–40 s |
| Intermedio | 40–90 s |
| Avanzado | 90 s – 3 min |
| Elite | 3+ min (cola larga de retención) |

---

## 5. Sistema de progresión

Todo local. Sin cuentas. Sin servidores.

### 5.1 High Score
- Mejor puntuación histórica.
- Se muestra en menú, HUD y pantalla de resultado.
- Animación especial al batir récord.

### 5.2 Skins (solo jugando)
Desbloqueo por hitos de **mejor puntuación** o **partidas jugadas** (lo que ocurra primero según tabla).

| Skin | Condición | Notas visuales |
|------|-----------|----------------|
| Default | Disponible | Orbe blanco/cyan |
| Ember | Score ≥ 50 | Naranja suave |
| Moss | Score ≥ 100 | Verde |
| Violet | Score ≥ 200 | Violeta apagado (no neón agresivo) |
| Gold | Score ≥ 350 | Dorado mate |
| Ghost | Score ≥ 500 | Semi-transparente |
| Dual | 100 partidas | Trail doble |
| Midnight | 7 días con misión diaria | Negro con borde claro |
| Prism | Score ≥ 1000 | Gradiente sutil animado |

*Paleta de skins siempre sobria; el “wow” es la forma/trail, no el glow excesivo.*

### 5.3 Misiones diarias (offline)
- Se regeneran a medianoche local del dispositivo.
- 1 misión activa por día (simple = mayor retención).
- Ejemplos rotativos:
  - Alcanza 80 puntos en una partida
  - Juega 5 partidas
  - Recoge 30 orbes
  - Sobrevive 60 segundos
  - Usa solo el carril central durante 20 s seguidos (avanzada, rotación rara)

**Recompensa:** medalla del día + progreso hacia títulos + moneda cosmética opcional **“Sparks”** (solo cosmética, no paywall).

### 5.4 Medallas
Logros permanentes, una sola vez:

| ID | Medalla | Condición |
|----|---------|-----------|
| first_run | Primer pulso | Terminar 1 partida |
| score_50 | Despertar | Score ≥ 50 |
| score_100 | En ritmo | Score ≥ 100 |
| score_250 | Enfoque | Score ≥ 250 |
| score_500 | Maestro | Score ≥ 500 |
| score_1000 | Leyenda | Score ≥ 1000 |
| games_50 | Persistente | 50 partidas |
| games_200 | Habitual | 200 partidas |
| daily_3 | Constancia | 3 misiones diarias |
| daily_7 | Semana perfecta | 7 misiones diarias |
| near_miss | Casi… | 10 partidas con score a ≤10 del récord |
| no_collect | Purista | Score ≥ 150 sin recoger orbes |

### 5.5 Títulos
Se muestran junto al nombre/perfil local:

| Título | Condición |
|--------|-----------|
| Novato | Por defecto |
| Aprendiz | Score ≥ 50 |
| Constante | 7 días jugados (no necesariamente seguidos) |
| Cazador de récords | Batir el récord 10 veces |
| Minimalista | Desbloquear 5 skins |
| Uno más | 500 partidas |
| Equilibrio | Score ≥ 750 |
| One more try. | Score ≥ 1500 |

### 5.6 Estadísticas personales
- Partidas jugadas
- Tiempo total jugado
- Mejor score
- Score promedio (últimas 20)
- Orbes recogidos
- Muertes por carril (curiosidad / insight)
- Racha de días jugados
- Medallas / títulos desbloqueados
- Skins desbloqueadas

---

## 6. Sistema procedural

### Principio
No hay niveles. Hay un **generador de segmentos** que produce patrones seguros y desafiantes.

### Unidad básica: Segmento
Cada segmento ocupa N filas de altura (ej. 1 fila = distancia de 1 obstáculo potencial).

```
LaneMask: bitflags L=1, C=2, R=4
Ejemplo:
  obstáculo en L+C → mask = 3 (R libre)
  obstáculo solo en C → mask = 2 (L y R libres)
```

**Regla de oro:** siempre debe existir **al menos 1 carril libre** y un camino alcanzable desde la posición actual considerando el tiempo de cambio de carril.

### Pipeline del generador
1. `Difficulty = f(score, time)` (§7)
2. Elegir **plantilla de patrón** según dificultad
3. Variar con seed (`runSeed + segmentIndex`)
4. Validar pathfinding lateral (¿el jugador puede llegar a tiempo?)
5. Insertar huecos de “respiración” cada X segmentos
6. Colocar orbes en carriles seguros (nunca dentro de obstáculo)

### Plantillas de patrón (ejemplos)
| ID | Nombre | Descripción | Dificultad min |
|----|--------|-------------|----------------|
| P01 | Single | 1 carril bloqueado | 0 |
| P02 | Double | 2 carriles bloqueados | 0.15 |
| P03 | Alternating | L-R-L-R en filas consecutivas | 0.25 |
| P04 | Wall gap | Muro de 2 + hueco lateral | 0.35 |
| P05 | Zigzag force | Obliga 2 cambios rápidos | 0.5 |
| P06 | Fake open | Abre centro luego cierra | 0.65 |
| P07 | Burst | Ráfaga densa + respiración | 0.8 |

### Seed
- Cada partida: `runSeed = timestamp XOR random`
- Reproduce runs para debug/balance (modo oculto o flag de desarrollo).

---

## 7. Algoritmo de dificultad

### Variables
```
t          = tiempo de partida (segundos)
score      = puntuación actual
d          = dificultad normalizada [0, 1]

speed      = velocidad de scroll
spawnGap   = distancia entre obstáculos
doubleRate = probabilidad de bloqueo doble
patternTier= índice de plantillas permitidas
```

### Curva recomendada
```
d = clamp(1 - exp(-score / 180), 0, 1)

speed      = lerp(baseSpeed, maxSpeed, smoothstep(d))
spawnGap   = lerp(maxGap, minGap, d)
doubleRate = lerp(0.05, 0.55, d^1.2)
patternTier= floor(d * numTiers)
```

### Valores iniciales de balance (v1 — a tunear en playtest)
| Parámetro | Inicio (d=0) | Final (d≈1) |
|-----------|--------------|-------------|
| Velocidad scroll | 220 px/s | 520 px/s |
| Gap entre obstáculos | 2.4 s equiv. | 0.85 s equiv. |
| Prob. doble bloqueo | 5 % | 55 % |
| Prob. orbe | 35 % | 20 % |
| Segmentos de respiración | cada 6 | cada 10 |

### Guardrails anti-frustración
- Nunca 3 cambios de carril obligatorios en < tiempo_cambio * 2.2
- Tras una ráfaga (P07), forzar 1–2 segmentos fáciles (P01)
- Primeros 8 segmentos de toda partida: solo P01–P02
- Cap de velocidad duro para no romper input en dispositivos lentos

### Puntuación
```
+1 por segundo sobrevivido (tick 10 Hz → +0.1)
+1 por orbe
+combo: orbes seguidos sin chocar → +1 extra cada 5 orbes de combo
Bonus de respiración: ninguno (evitar complejidad)
Score mostrado como entero
```

---

## 8. Diseño UI/UX completo

### Principios
1. **Una acción primaria por pantalla**
2. **El banner nunca tapa controles** — safe area inferior = altura banner + margen
3. **Contraste alto** en modo oscuro (default) y claro
4. **Feedback < 100 ms** en toques
5. **Tipografía expresiva** pero legible (display para título, sans geométrica para UI)
6. **Sin cards innecesarias** — listas limpias, jerarquía tipográfica
7. **Motion con propósito:** transición de carril, pulse de score, reveal de récord

### Sistema visual
```
--bg-0:        #0B0D10   (fondo base oscuro)
--bg-1:        #12151A
--text-0:      #F2F4F7
--text-1:      #9AA3AD
--accent:      #5EEAD4   (teal, no púrpura)
--danger:      #FB7185
--success:     #86EFAC
--lane-line:   #1F2933
--banner-safe: 60–68 dp + padding
```

Modo claro (inverso controlado, no blanco puro):
```
--bg-0: #F3F5F7
--bg-1: #FFFFFF
--text-0: #0B0D10
--accent: #0F766E
```

### Tipografías propuestas
- Display / logo: **Space Grotesk** o **Outfit**
- UI: **Manrope** o **DM Sans**
- Evitar Inter / Roboto / Arial como voz de marca

### Feedback visual
- Cambio de carril: ease + squash leve
- Orbe recogido: ring expand + partículas (8–12, baratas)
- Near miss: flash lateral del carril
- Nuevo récord: ripple desde el score + haptic ligero
- Muerte: freeze frame 120 ms → fade a resultado

### Accesibilidad
- Tamaño mínimo de toque 48 dp
- Reducir motion (opción)
- Daltonismo: obstáculos por forma/posición, no solo color
- Textos legibles con Dynamic Type / escalado del SO

---

## 9. Diseño de pantallas

### 9.1 Splash
- logo One more try. centrado
- Fondo con gradiente sutil + grain muy leve
- Duración máx. 1.5 s (o hasta cargar save)
- Sin spinner agresivo

### 9.2 Menú principal
```
┌─────────────────────────┐
│  One more try.                    │  ← marca hero
│  Best  342              │
│                         │
│      [  PLAY  ]         │  ← CTA única
│                         │
│  Skins  Stats  Medals   │  ← secundarios texto
│                         │
│  Daily: Reach 80  [== ] │  ← una línea
│─────────────────────────│
│     [ AD BANNER ]       │  ← siempre reservado
└─────────────────────────┘
```

### 9.3 Tutorial (solo 1ª vez)
- Overlay: “Tap to change lane”
- 3 obstáculos guiados lentos
- Skip disponible
- No vuelve a mostrarse (flag en save)

### 9.4 HUD de partida
```
Score (centro-arriba)
Best (pequeño, esquina)
Carriles + orbe
Sin pausa prominente (botón discreto arriba-izquierda opcional)
Safe bottom para banner
```
**Nota:** Durante partida el banner puede permanecer (ingresos) pero el playfield termina arriba del safe area.

### 9.5 Resultado / Game Over
```
Score grande
“NEW BEST” si aplica
+ medalla/misión si se completó
[ OTRA VEZ ]  ← primario
[ Menú ]
Banner safe abajo
```

### 9.6 Skins
- Lista/carrusel horizontal simple
- Preview del orbe animado
- Candado + condición en una línea
- Equipar con un toque

### 9.7 Estadísticas
- Lista tipográfica limpia (label / valor)
- Sin gráficos pesados en v1 (opcional sparkline liviana luego)

### 9.8 Medallas / Títulos
- Grid o lista con estado locked/unlocked
- Locked: silueta + condición

### 9.9 Ajustes
- Música on/off
- SFX on/off
- Modo oscuro / claro / sistema
- Reducir motion
- Haptics on/off
- Créditos / privacidad (AdMob)
- Restaurar no aplica (sin IAP)

---

## 10. Arquitectura del proyecto

### Motor: Flutter
**Por qué Flutter (decisión de bajo costo):**
- Un codebase → Android + iOS
- UI moderna y rápida de iterar
- Buen rendimiento 2D con CustomPainter / Flame (capa game)
- Plugins maduros de AdMob
- Menor costo que Unity para este scope 2D minimalista
- Arranque rápido y APK liviano si se cuida el asset budget

**Capa de juego:** Flutter + `Flame` (motor 2D ligero) **o** `CustomPainter` puro.  
**Recomendación:** **Flame** para organización de componentes sin over-engineering.

### Arquitectura en capas
```
┌──────────────────────────────────────┐
│ Presentation (UI / screens / theme)  │
├──────────────────────────────────────┤
│ Application (controllers / use cases)│
├──────────────────────────────────────┤
│ Domain (entities / rules / scores)   │
├──────────────────────────────────────┤
│ Game (Flame: player, obstacles, fx)  │
├──────────────────────────────────────┤
│ Generation (procedural / difficulty) │
├──────────────────────────────────────┤
│ Data (local save / prefs / audio)    │
├──────────────────────────────────────┤
│ Services (ads banner / haptics / ...)│
└──────────────────────────────────────┘
```

### Reglas
- La UI **no** genera niveles
- El generador **no** conoce widgets
- Ads **solo** en capa Services; el game loop no depende de ads
- Configuración en archivos/constantes versionables
- Nuevos modos = nuevo `GameMode` + generator strategy, sin reescribir el core

### Extensibilidad (futuros modos)
```dart
abstract class GameMode {
  String get id;
  DifficultyCurve get curve;
  SegmentGenerator get generator;
  ScoringRules get scoring;
}
```
Modos futuros: Zen (velocidad fija), Hardcore (2 carriles), Mirror, Daily Seed compartido offline (seed del día), etc.

---

## 11. Organización de carpetas

```
one_more_try/
├── android/
├── ios/
├── assets/
│   ├── audio/
│   │   ├── music_loop.ogg
│   │   └── sfx/
│   ├── fonts/
│   └── images/
│       └── skins/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── constants/
│   │   ├── theme/
│   │   ├── utils/
│   │   └── result.dart
│   ├── domain/
│   │   ├── entities/
│   │   ├── achievements/
│   │   ├── missions/
│   │   ├── progression/
│   │   └── scoring/
│   ├── generation/
│   │   ├── segment.dart
│   │   ├── patterns.dart
│   │   ├── difficulty.dart
│   │   └── segment_generator.dart
│   ├── game/
│   │   ├── one_game.dart
│   │   ├── components/
│   │   ├── effects/
│   │   └── systems/
│   ├── data/
│   │   ├── local_storage.dart
│   │   ├── save_models.dart
│   │   └── repositories/
│   ├── services/
│   │   ├── ads_service.dart
│   │   ├── audio_service.dart
│   │   ├── haptics_service.dart
│   │   └── settings_service.dart
│   ├── presentation/
│   │   ├── screens/
│   │   ├── widgets/
│   │   ├── navigation/
│   │   └── controllers/
│   └── di/
│       └── injector.dart
├── test/
├── GAME_DESIGN_DOCUMENT.md
├── pubspec.yaml
└── README.md
```

---

## 12. Clases principales

| Clase | Responsabilidad |
|-------|-----------------|
| `OneApp` | Root MaterialApp, tema, rutas |
| `GameController` | Orquesta start/retry/game over, score, pause |
| `OneGame` (Flame `FlameGame`) | Mundo, update loop, capas |
| `PlayerComponent` | Orbe, carril, animación, hitbox |
| `ObstacleComponent` | Bloque, mask de carril, reciclaje |
| `CollectibleComponent` | Orbes de score |
| `SegmentGenerator` | Produce segmentos procedurales |
| `DifficultyCurve` | Mapea score/tiempo → parámetros |
| `CollisionSystem` | Detecta hits / near miss |
| `ScoreService` | Puntos, combos, best |
| `SaveRepository` | Leer/escribir progreso local |
| `PlayerProgress` | Skins, medallas, títulos, stats |
| `DailyMissionService` | Misión del día offline |
| `AchievementTracker` | Evalúa medallas al game over |
| `AudioService` | Música / SFX con pooling mínimo |
| `AdsService` | Carga y muestra **solo** banner |
| `SettingsController` | Preferencias de usuario |
| `ThemeController` | Claro / oscuro / sistema |
| `SkinCatalog` | Definición y desbloqueos |
| `BannerSafeArea` | Padding global inferior anti-solape |

---

## 13. Flujo completo del juego

```
App launch
  → Load local save (SharedPreferences / Hive)
  → Init audio (lazy)
  → Init AdsService.loadBanner() (no bloquea play)
  → Splash
  → Home
       ├─ Play → create runSeed → OneGame.start()
       │           → Generator warm first segments
       │           → Gameplay loop
       │           → Collision → GameController.endRun()
       │               → Update stats
       │               → Check achievements / mission / titles / skins
       │               → Persist save
       │               → Show ResultScreen
       │                    ├─ Retry → new run
       │                    └─ Home
       ├─ Skins → equip → save
       ├─ Stats
       ├─ Medals
       └─ Settings
```

### Estados de partida
`idle → starting → playing → dying → results`

### Persistencia
Autosave en:
- Fin de partida
- Cambio de settings/skin
- Completar misión
- App lifecycle `paused` / `inactive`

---

## 14. Balance de dificultad

### Objetivos de métrica (diseño)
| Métrica | Objetivo |
|---------|----------|
| % jugadores que pasan score 30 en sesión 1 | ≥ 70 % |
| % que baten su récord en sesión 1 | ≥ 40 % |
| Duración media partida día 1 | 35–55 s |
| Retry rate inmediato | ≥ 60 % |
| Churn por “muerte injusta” (feedback cualitativo) | mínimo |

### Fases de dificultad en una run
1. **0–20 score:** enseñanza, huecos amplios
2. **20–80:** competencia básica, dobles ocasionales
3. **80–180:** zigzag, lectura anticipada
4. **180–350:** ráfagas + respiración
5. **350+:** precisión alta, velocidad cerca del cap

### Metodología de tuneo
1. Grabar seeds problemáticos
2. Telemetría **local opcional** en debug (no servidor en v1)
3. Ajustar curvas en `difficulty.dart` sin tocar gameplay code
4. Playtest con 5–10 personas ajenas al proyecto

---

## 15. Sistema de guardado

### Tecnología
- **Hive** o **SharedPreferences** + JSON
- Recomendación: **Hive** (rápido, tipado, offline, sin SQL)

### Modelo `SaveData`
```json
{
  "version": 1,
  "bestScore": 342,
  "totalGames": 128,
  "totalPlayTimeSec": 5402,
  "totalOrbs": 890,
  "unlockedSkins": ["default", "ember", "moss"],
  "equippedSkin": "ember",
  "medals": ["first_run", "score_50"],
  "titleId": "aprendiz",
  "stats": { "deathsPerLane": [40, 50, 38], "avgScore20": [..] },
  "daily": {
    "date": "2026-07-26",
    "missionId": "reach_80",
    "progress": 45,
    "completed": false
  },
  "settings": {
    "music": true,
    "sfx": true,
    "theme": "dark",
    "reduceMotion": false,
    "haptics": true
  },
  "flags": { "tutorialDone": true }
}
```

### Migraciones
- Campo `version`
- Migradores `v1 → v2` al añadir modos/campos
- Nunca borrar progreso silenciosamente

### Privacidad
- Sin cuenta
- Sin analytics de terceros obligatorios en v1 (opcional luego, opt-in)
- AdMob requiere política de privacidad en store listing

---

## 16. Integración Google AdMob (solo banner)

### Reglas de producto (innegociables)
- **Solo** `BannerAd` inferior
- **Prohibido:** interstitial, rewarded, app open, native que tape UI
- El banner tiene contenedor fijo; el layout siempre reserva altura
- Si el anuncio falla al cargar: espacio vacío colapsable **o** placeholder del mismo alto (preferible mantener alto estable para no saltar UI)
- **Recomendación UX:** mantener altura reservada siempre → cero layout jump

### Implementación
- Plugin: `google_mobile_ads`
- `AdsService`:
  - `initialize()`
  - `loadBanner()`
  - `disposeBanner()`
  - IDs de producción vs test separados por flavor
- Mostrar banner en: Home, Result, Skins, Stats, Settings
- Durante gameplay: **sí mostrar** (monetización principal) con playfield padded

### Cumplimiento
- UMP / consent message (EEA/UK) cuando corresponda
- App ID en `AndroidManifest` / `Info.plist`
- Nunca click inducido
- Frecuencia: N/A (banner persistente estático)

### Estimación de negocio (orden de magnitud, no promesa)
- eCPM banner varía mucho por país
- Volumen + retención + sesiones largas de “retry” compensan eCPM bajo
- Hipótesis: simplicidad + viral loop > ARPU alto por usuario

---

## 17. Publicación en Google Play

### Checklist
1. Cuenta Google Play Console
2. Firmar app (Play App Signing)
3. Package único + versionCode/versionName
4. Privacy Policy URL (hosting simple)
5. Data safety form (AdMob: sí, publicidad)
6. Target API level vigente
7. Contenido: PEGI/ESRB Everyone / 3+
8. Screenshots (teléfono): menú, gameplay, récord, skins
9. Feature graphic 1024×500
10. Ícono 512×512 (círculo One more try.)
11. Descripción corta + larga orientada a keywords: casual, endless, offline, simple
12. Categoría: Arcade / Casual
13. Ads declared: Yes
14. Prueba interna → cerrada → producción
15. (Opcional paralelo) App Store con mismos assets

### ASO (descubrimiento orgánico)
- Título: `One more try.` (o `One more try. — Endless Lane`)
- Enfocarse en: offline, one tap, endless, high score
- Video de 15–30 s: muerte → retry → récord (loop emocional)

### Mantenimiento post-lanzamiento
- Hotfix solo si crash rate alto
- Updates de contenido livianos: skins, misiones, un modo nuevo
- Evitar features que requieran servidor

---

## 18. Optimización de rendimiento

### Objetivos técnicos
| Métrica | Objetivo |
|---------|----------|
| Cold start a menú | < 2 s en mid-range |
| RAM en gameplay | < 150 MB ideal |
| Batería | sin wakelock innecesario; 60 FPS cap |
| APK size | < 25 MB (ideal < 15 MB) |
| Frame | 60 FPS estables; degradar FX si baja |

### Técnicas
- Object pooling de obstáculos/orbes/partículas
- No crear TextStyles por frame
- Assets de audio comprimidos (OGG), música loop corta
- Skins = colores/shaders simples, no spritesheets enormes
- Pausar motor al ir a background
- Banner: no recargar en loop agresivo
- Evitar sombras múltiples / blur caros
- `RepaintBoundary` en UI estática
- Generación de segmentos en chunks, no toda la run
- Sin física 3D; colisiones AABB/círculo manuales

### Modo bajo consumo (opcional settings)
- Menos partículas
- Trail off
- 30 FPS cap opcional

---

## 19. Ideas para futuras actualizaciones

Priorizadas por **bajo costo / alta retención**:

| Update | Esfuerzo | Impacto |
|--------|----------|---------|
| Nuevas skins + títulos | Bajo | Medio |
| Modo Zen (velocidad fija, sin death stress) | Bajo | Alto para audiencia amplia |
| Modo Hardcore (2 carriles) | Bajo | Alto para hardcore |
| Daily Seed (misma run del día, score local) | Medio | Alto (comparación social manual) |
| Temas de color de escenario | Bajo | Medio |
| Contrarreloj 60 s | Bajo | Medio |
| Medallas nuevas estacionales (fecha local) | Bajo | Medio |
| Widget de récord (Android) | Medio | Bajo–medio |
| iOS launch parity polish | Medio | Mercado extra |
| Modo coop pasivo (ghost de tu mejor run) | Medio | Alto |

**Explicitamente fuera de scope a largo plazo cercano:** multijugador online, battle pass, IAP, mid-core meta.

---

## 20. Código listo para producción (plan de entrega)

> **Este documento debe aprobarse antes de escribir código.**

### Tras aprobación, el desarrollo se entregará en este orden
1. Scaffold Flutter + arquitectura de carpetas
2. Core gameplay (carriles, input, colisión, score)
3. Generador procedural + curva de dificultad
4. UI screens + tema claro/oscuro + banner safe area
5. Guardado local + progresión (skins, medallas, misiones, títulos, stats)
6. Audio + haptics + FX
7. AdMob banner (IDs de test)
8. Pulido, tests unitarios del generador/path validation
9. Builds Android release + guía iOS
10. Comentarios en código orientados a mantenimiento (por qué, no ruido)

### Definición de “producción”
- Sin crashes en el flujo feliz
- Guardado robusto con versión
- Ads solo banner, con consent hook listo
- Offline total del gameplay y meta
- README de build/sign/publish
- Código comentado en módulos críticos (generator, difficulty, ads, save)

---

## Decisión de producto resumida

| Decisión | Elección | Motivo |
|----------|----------|--------|
| Género | Endless lane switch (1 tap) | Máxima retención / mínimo arte |
| Nombre | One more try. | Marca clara, memorable, viral |
| Motor | Flutter + Flame | 1 dev, 2 OS, costo bajo |
| Ads | Solo banner inferior | UX agradable + pasivo |
| Meta | Skins / daily / medals / titles | Retención offline |
| Niveles | 100 % procedural | Cero contenido manual |
| Online | Ninguno | Cero mantenimiento de servers |

---

## Riesgos y mitigaciones

| Riesgo | Mitigación |
|--------|------------|
| Sensación de “ya jugado” | Arte/audio/feel distintivos + meta offline |
| Dificultad injusta | Path validation + perdón de hitbox + respiración |
| eCPM bajo de banner | Volumen de sesiones por retry loop |
| Rechazo store por ads | Solo banner, política clara, UMP |
| Scope creep | Este GDD es la constitución de v1 |

---

## Criterios de aceptación v1 (Go / No-Go)

- [ ] Partida empieza en < 3 s desde Play
- [ ] Se entiende sin tutorial escrito largo
- [ ] Runs procedurales infinitas con dificultad creciente
- [ ] High score + stats + al menos 8 skins + medallas + títulos + 1 daily
- [ ] Banner inferior nunca tapa CTAs
- [ ] Offline completo
- [ ] Modo oscuro + claro
- [ ] Guardado automático fiable
- [ ] Sin interstitial / rewarded / IAP

---

## Aprobación

**Estado:** ⏳ Esperando aprobación del stakeholder

Para comenzar el desarrollo, confirmar:
**Aprobado** (2026-07-26): concepto lane-switch + stack Flutter/Flame + nombre **One more try.**

Implementación en curso según el plan de la §20.
