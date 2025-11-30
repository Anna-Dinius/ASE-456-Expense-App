function loadNav() {
	const isIndexPage =
		location.pathname.endsWith('index.html') || location.pathname === '/';

	// ✅ Root-relative path works on GitHub Pages
	const navPath = '/github-io/components/nav.html';

	fetch(navPath)
		.then((response) => {
			if (!response.ok) throw new Error('Nav fetch failed');
			return response.text();
		})
		.then((data) => {
			const parser = new DOMParser();
			const doc = parser.parseFromString(data, 'text/html');
			const links = doc.querySelectorAll('a.nav-link, .navbar-brand');

			links.forEach((link) => {
				const href = link.getAttribute('href');

				// Rewrite paths
				if (isIndexPage && href !== 'index.html') {
					link.setAttribute('href', 'github-io/' + href);
				} else if (!isIndexPage && href === 'index.html') {
					link.setAttribute('href', '../index.html');
				}

				// Highlight active link
				const currentPage = location.pathname.split('/').pop();
				if (href === currentPage || (href === 'index.html' && isIndexPage)) {
					link.classList.add('active');
				}
			});

			document.getElementById('nav-placeholder').innerHTML = doc.body.innerHTML;
		})
		.catch((err) => {
			console.error('Nav load error:', err);
			document.getElementById('nav-placeholder').innerHTML =
				"<div class='alert alert-danger'>Navigation failed to load.</div>";
		});
}

document.addEventListener('DOMContentLoaded', loadNav);
