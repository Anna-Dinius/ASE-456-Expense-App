// github-io/js/nav-loader.js

function loadNav() {
	const isIndexPage =
		location.pathname.endsWith('index.html') || location.pathname === '/';

	// Choose correct path to nav.html
	const navPath = isIndexPage
		? 'github-io/components/nav.html' // from root
		: '../github-io/components/nav.html'; // from inside github-io/

	fetch(navPath)
		.then((response) => response.text())
		.then((data) => {
			const parser = new DOMParser();
			const doc = parser.parseFromString(data, 'text/html');
			const links = doc.querySelectorAll('a.nav-link, .navbar-brand');

			links.forEach((link) => {
				const href = link.getAttribute('href');
				if (isIndexPage && href !== 'index.html') {
					// On index page, prepend github-io/
					link.setAttribute('href', 'github-io/' + href);
				} else if (!isIndexPage && href === 'index.html') {
					// On subpages, index should point back up
					link.setAttribute('href', '../index.html');
				}
			});

			document.getElementById('nav-placeholder').innerHTML = doc.body.innerHTML;
		});
}

document.addEventListener('DOMContentLoaded', loadNav);
