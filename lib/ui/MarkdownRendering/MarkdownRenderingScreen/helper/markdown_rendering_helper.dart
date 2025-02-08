import 'package:flutter/material.dart';

class MarkdownRenderingHelper {
  String prettifyHtml(
    String html,
    BuildContext context,
  ) {
    // List<String> split = html.split("\n");
    // split.forEach((element) {
    //   print(element);
    // });
    // theme colors
    String surface = Theme.of(context).colorScheme.surface.toHexString();
    String onSurface = Theme.of(context).colorScheme.onSurface.toHexString();
    String surfaceTint =
        Theme.of(context).colorScheme.surfaceTint.toHexString();

    String divider = Theme.of(context).dividerColor.toHexString();

    String primary = Theme.of(context).colorScheme.primary.toHexString();
    String onPrimary = Theme.of(context).colorScheme.onPrimary.toHexString();

    String secondary = Theme.of(context).colorScheme.secondary.toHexString();
    String onSecondary =
        Theme.of(context).colorScheme.onSecondary.toHexString();

    String tertiary = Theme.of(context).colorScheme.tertiary.toHexString();
    String onTertiary = Theme.of(context).colorScheme.onTertiary.toHexString();

    String primaryContainer =
        Theme.of(context).colorScheme.primaryContainer.toHexString();
    String onPrimaryContainer =
        Theme.of(context).colorScheme.onPrimaryContainer.toHexString();

    String secondaryContainer =
        Theme.of(context).colorScheme.secondaryContainer.toHexString();
    String onSecondaryContainer =
        Theme.of(context).colorScheme.onSecondaryContainer.toHexString();

    String tertiaryContainer =
        Theme.of(context).colorScheme.tertiaryContainer.toHexString();
    String onTertiaryContainer =
        Theme.of(context).colorScheme.onTertiaryContainer.toHexString();

    String textColor = TextTheme.of(context).bodySmall!.color!.toHexString();

    // css
    String css = """
:root {
  --surface: $surface;
  --on-surface: $onSurface;
	--surface-tint: $surfaceTint;

	--divider-color: $divider;

  --primary: $primary;
  --on-primary: $onPrimary;

  --secondary: $secondary;
  --on-secondary: $onSecondary;

  --tertiary: $tertiary;
  --on-tertiary: $onTertiary;

  --primary-container: $primaryContainer;
  --on-primary-container: $onPrimaryContainer;

  --secondary-container: $secondaryContainer;
  --on-secondary-container: $onSecondaryContainer;

  --tertiary-container: $tertiaryContainer;
  --on-tertiary-container: $onTertiaryContainer;

  --text-color: $textColor;
}

/*  HEADINGS  */

h1, h2, h3, h4, h5, h6 {
    font-weight: 600;
    color: var(--text-color); 
		margin-top: 0;
    margin-bottom: 0.5em;
}

/* Specific Heading Sizes */
h1 {
    font-size: 32px; /* 36px */
    line-height: 1.1;
}

h2 {
    font-size: 28px; /* 28px */
    line-height: 1.2;
}

h3 {
    font-size: 24px; /* 24px */
    line-height: 1.25;
}

h4 {
    font-size: 20px; /* 20px */
    line-height: 1.3;
}

h5 {
    font-size: 18px; /* 18px */
    line-height: 1.35;
}

h6 {
    font-size: 16px;
    line-height: 1.4;
}

h1, h2, h3 {
    border-bottom: 1px solid var(--divider-color);
    padding-bottom: 0.3em;
}

h1, h2, h3, h4, h5, h6 {
    margin-top: 1.2em;
    margin-bottom: 1em;
}



body {
    font-size: 14px;
    line-height: 1.5;
    color: var(--on-surface); 
    margin: 0;
    padding: 20px;
}

/* Centered container like GitHub */
.container {
    max-width: 900px;
    margin: 0 auto;
    background: white;
    padding: 20px;
    border: 1px solid #d0d7de;
    border-radius: 6px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}


/* LINKS */

a {
    color: #0969da;
    text-decoration: none;
}

a:hover {
    text-decoration: underline;
}


/* CODE BLOCKS */

code {
    font-family: monospace;
    background-color: #000000;
    padding: 2px 4px;
    border-radius: 4px;
}


/* LISTS */

ul {
    padding-left: 20px;
}


/*  HORIZONTAL RULE */

hr {
    border: 0;
    height: 1px;
    background: var(--divider-color);
    margin: 20px 0;
}


/*  TABLES  */

.table-container {
    width: 100%;
    overflow-x: auto;
}

table {
    border-collapse: collapse;
    background-color: var(--secondary-container);
		color: var(--on-secondary-container);
}

th, td {
    border: 1px solid var(--divider-color);
    padding: 8px;
    text-align: left;
}

th {
    background-color: var(--tertiary-container);
    font-weight: 600;
		color: var(--on-tertiary-container)
}

tr:nth-child(even) {
    background-color: var(--tertiary-container);
		color: var(--on-tertiary-container)
}


""";

    // html
    html = '''
<!DOCTYPE html>
<html>
<head>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- KaTeX CSS -->

  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css">

  <!-- Optional: Auto-render extension -->

  <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>
  <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/contrib/auto-render.min.js"></script>

	<style>
		$css
	</style> 

</head>
<body>
		$html
<div class="spacer" style="height: 150px;"></div>


<script>
    document.addEventListener("DOMContentLoaded", function () {
        renderMathInElement(document.body, {
            delimiters: [
                { left: "\$", right: "\$", display: false },
								{ left: "%\$", right: "\$%", display: true }
            ]
        });
    });
</script>

<script type="module">
  import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';
	
  document.addEventListener("DOMContentLoaded", function () {
    mermaid.initialize({
      theme: 'base',
      themeVariables: {
        primaryColor: '$primaryContainer',
        primaryTextColor: '$onPrimaryContainer',
        primaryBorderColor: '$divider',
        lineColor: '$divider',
        nodeTextColor: '$textColor',
        secondaryColor: '$secondaryContainer',
        tertiaryColor: '$tertiaryContainer',
        edgeLabelBackground: '$surfaceTint'
      }
    });

    // Force Mermaid to render all diagrams
    mermaid.init();
  });

</script>

</body>
		''';
    return html;
  }
}

extension ColorToHexString on Color {
  String toHexString() {
    return "#${value.toRadixString(16).padLeft(8, '0').substring(2)}";
  }
}
