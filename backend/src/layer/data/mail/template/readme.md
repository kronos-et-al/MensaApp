# Build the html template

To build the HTML template [install tailwind](https://tailwindcss.com/docs/installation).

Run `npx tailwindcss -i ./style.css -o output.css -m --watch` to generate the stylesheet when making any changes.

Once done, inline `output.css` into the html file as necessary to send it as an email.