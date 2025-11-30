function loadNav() {
	const isIndexPage =
		location.pathname.endsWith('index.html') || location.pathname === '/';

	// Detect repo root dynamically
	const repoRoot = '/' + window.location.pathname.split('/')[1];
	const navPath = `${repoRoot}/github-io/components/nav.html`;

	fetch(navPath)
		.then((response) => {
			if (!response.ok) throw new Error('Nav fetch failed');
			return response.text();
		})
		.then((data) => {
			const parser = new DOMParser();
			const doc = parser.parseFromString(data, 'text/html');

			document.getElementById('nav-placeholder').innerHTML = doc.body.innerHTML;
		})
		.catch((err) => {
			console.error('Nav load error:', err);
			document.getElementById('nav-placeholder').innerHTML =
				"<div class='alert alert-danger'>Navigation failed to load.</div>";
		});
}

document.addEventListener('DOMContentLoaded', loadNav);
