# Smart Home UI Asset Prompt

This document is the shared visual prompt specification for SmartHome room and device images.
Use it as the base prompt for living room, bedroom, kitchen, bathroom, balcony, curtains, and device assets.

## Global Style

Tencent Marvis style, minimalist, abstract, 2.5D isometric smart home interior, modern smart home, Scandinavian minimalism, rounded geometry, low-saturation warm white palette, soft wood material, clean negative space, UI asset, app homepage asset, product design illustration rather than architectural rendering, soft skeuomorphism, Apple Human Interface inspired, no people, no text, no labels, no logo, pure background, suitable for overlaying interactive hotspots.

English core prompt:

```text
Minimal abstract isometric smart home interior, Tencent Marvis style, Apple Human Interface inspired, soft beige palette, rounded geometry, clean Scandinavian furniture, orthographic 45-degree isometric camera, simplified 3D shapes, low-poly but premium, soft ambient lighting, smooth matte materials, UI illustration, high-end smart home dashboard asset, consistent room layout, no people, no text, no labels, no logo, no decorations, no photorealism, designed for interactive smart home application.
```

## Fixed Camera

```text
45-degree isometric view.
Orthographic camera.
Fixed camera.
Fixed focal length.
Fixed layout.
All variants must keep exactly the same image composition.
Only time of day and lighting are allowed to change.
Do not move, add, remove, resize, rotate, or restyle any furniture.
```

## Rendering Requirements

```text
Ultra clean.
Minimal.
Modern.
Soft shadow.
Soft global illumination.
Smooth surface.
Rounded edge.
Low contrast.
Soft ambient occlusion.
Simple material.
No texture noise.
No photorealistic detail.
High-end app UI illustration.
3D icon style.
Premium smart home dashboard.
High resolution.
```

## Room Layouts

Living room:

```text
Open modern living room.
L-shaped sofa.
Coffee table.
TV.
TV cabinet.
Wall-mounted air conditioner.
Window.
Double-layer curtains.
Air purifier.
Robot vacuum.
Green plants.
Side cabinet.
Floor plant.
Rug.
Keep all furniture in fixed positions.
```

Bedroom:

```text
Modern minimalist bedroom.
Double bed.
Bedside table.
Wardrobe.
Wall-mounted air conditioner.
Large window.
Double-layer curtains.
Robot vacuum.
Side cabinet.
Green plants.
Bedside lamp.
Hidden LED light strip.
Rug.
Keep all furniture in fixed positions.
```

Kitchen:

```text
Modern minimalist kitchen.
L-shaped counter.
Sink.
Stove.
Range hood.
Refrigerator.
Kitchen island or small dining island.
Simple dining stools.
Small green plants.
Soft wood cabinet fronts.
Keep all furniture and appliances in fixed positions.
```

Bathroom:

```text
Modern minimalist bathroom.
Vanity.
Mirror cabinet.
Toilet.
Glass shower enclosure.
Shower head.
Small window.
Bath mat.
Small green plant.
Rounded beige and soft wood materials.
Keep all furniture and fixtures in fixed positions.
```

Balcony:

```text
Modern minimalist balcony laundry area.
Washer.
Storage cabinet.
Small folding table or lounge chair.
Indoor plants.
Large window or open balcony glazing.
Soft wood cabinet.
Clean floor.
Keep all furniture and appliances in fixed positions.
```

## Lighting States

Day OFF:

```text
Daytime outside the window.
Natural sunlight.
All indoor lights off.
Bedside lamps off.
LED light strips off.
All warm lights off.
Only natural daylight.
Overall cool white.
Soft shadows.
```

Day ON:

```text
Daytime outside the window.
Natural sunlight plus indoor lights on.
Bedside lamps on.
LED light strips on.
Warm yellow indoor lighting.
Mixed natural light and artificial light.
Overall warmer than Day OFF.
Keep all furniture positions unchanged.
```

Night OFF:

```text
Night scene outside the window.
Deep blue night sky.
All indoor lights off.
Bedside lamps off.
LED light strips off.
Only very weak moonlight.
Overall blue gray.
Do not make it completely black.
Furniture must remain clearly visible.
Keep all furniture positions unchanged.
```

Night ON:

```text
Night scene outside the window.
Warm yellow indoor lighting.
Bedside lamps on where present.
Hidden LED light strips on where present.
Soft ambient light.
Comfortable home atmosphere.
Do not make it too bright.
Keep the night feeling.
Keep all furniture positions unchanged.
```

## Negative Prompt

```text
No people.
No text.
No labels.
No logo.
No watermark.
No UI.
No icons.
No realistic architecture.
No excessive decoration.
No clutter.
No messy objects.
No ceiling lights.
No camera perspective distortion.
No dramatic lighting.
No heavy texture.
No glossy floor.
No reflections.
No strong shadows.
No colorful furniture.
No black furniture.
No vintage style.
No industrial style.
No ornaments.
No paintings with details.
No photorealistic rendering.
```

## Edit Prompt Template

Use this template when editing an existing room image into a new lighting state:

```text
Use case: lighting-weather
Asset type: SmartHome app 2.5D room background
Input image role: edit target. Preserve the exact room layout, object positions, camera angle, scale, crop, and composition.
Primary request: Convert only the time of day and lighting to <STATE>.
Style: Tencent Marvis style, minimal abstract isometric smart home interior, Apple Human Interface inspired, soft beige palette, rounded geometry, clean Scandinavian furniture, orthographic 45-degree isometric camera, simplified premium 3D UI illustration, smooth matte materials.
Lighting: <STATE LIGHTING DESCRIPTION>.
Constraints: keep all furniture, appliances, windows, walls, plants, floor shape, and empty clickable-space layout unchanged; do not add, remove, resize, rotate, or move any object; no text; no labels; no logo; no people; no UI controls; no photorealism.
Avoid: excessive decoration, clutter, realistic architecture, dramatic lighting, heavy texture, glossy floor, reflections, strong shadows, colorful furniture, black furniture, vintage style, industrial style, ornaments, detailed paintings.
```
