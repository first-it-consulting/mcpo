# Setting up a Helm Repository with GitHub Pages

To make your Helm chart available via `helm repo add`, you need to set up a proper Helm repository. Here's how to do it using GitHub Pages:

## Step 1: Create a `gh-pages` branch

```bash
# Create and switch to gh-pages branch
git checkout --orphan gh-pages
git rm -rf .

# Create index.yaml and package your chart
helm package .
helm repo index . --url https://first-it-consulting.github.io/helm-mcpo/

# Commit and push
git add .
git commit -m "Initial helm repository setup"
git push -u origin gh-pages
```

## Step 2: Enable GitHub Pages

1. Go to your GitHub repository settings
2. Navigate to "Pages" section
3. Select "Deploy from a branch"
4. Choose "gh-pages" branch and "/ (root)" folder
5. Save the settings

## Step 3: Update your charts

Whenever you update your chart:

```bash
# On your main branch, update version in Chart.yaml
# Then switch to gh-pages branch
git checkout gh-pages

# Package the new version
helm package ../path/to/your/chart
helm repo index . --url https://first-it-consulting.github.io/helm-mcpo/

# Commit and push
git add .
git commit -m "Update helm repository"
git push
```

## Step 4: Test the repository

After GitHub Pages is set up (may take a few minutes), users can add your repository:

```bash
helm repo add mcp-helm https://first-it-consulting.github.io/helm-mcpo/
helm repo update
helm install mcpo mcp-helm/mcpo
```

## Alternative: Use GitHub Actions for Automation

Create `.github/workflows/helm-release.yml`:

```yaml
name: Release Charts

on:
  push:
    branches:
      - main
    paths:
      - 'Chart.yaml'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Configure Git
        run: |
          git config user.name "$GITHUB_ACTOR"
          git config user.email "$GITHUB_ACTOR@users.noreply.github.com"

      - name: Install Helm
        uses: azure/setup-helm@v3

      - name: Run chart-releaser
        uses: helm/chart-releaser-action@v1.5.0
        env:
          CR_TOKEN: "${{ secrets.GITHUB_TOKEN }}"
```

This will automatically create releases and update the Helm repository when you update Chart.yaml.
