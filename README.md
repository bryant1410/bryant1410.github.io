# [Personal website](https://santi.uy/)

This is the source of [my personal website](https://santi.uy/), served with GitHub Pages.

It's a single dependency-free static page ([`index.html`](index.html)) with inline CSS and inline SVG icons; there's no
build step. To preview it locally, open `index.html` in a browser or run `python3 -m http.server` and visit
<http://localhost:8000/> (analytics only load on the production domain).

After changing how the page looks, regenerate the link-preview image ([`img/opengraph.png`](img/opengraph.png)) with
[`scripts/update-opengraph.sh`](scripts/update-opengraph.sh) (needs Chrome or Chromium).

The design was originally based on
[Start Bootstrap - Resume](https://github.com/StartBootstrap/startbootstrap-resume). Brand icons are from
[Font Awesome Free](https://fontawesome.com) (CC BY 4.0).

The CV linked from the page (`/resume/main.pdf`) is served from a separate repository.
