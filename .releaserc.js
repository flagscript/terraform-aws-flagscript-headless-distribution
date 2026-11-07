const { name } = require("./package.json");
const moduleName = name.replace(/^@[^/]+\//, "");
const tarExcludes = [
  "./.config",
  "./.github",
  "./.pnpm-store",
  "./.vscode",
  "./node_modules",
  "./reports",
  "./tests",
  "./.gitattributes",
  "./.gitignore",
  "./.gitlab-ci.yml",
  "./.lefthook.yaml",
  "./.releaserc.js",
  "./.terraform.lock.hcl",
  "./package.json",
  "./pnpm-lock.yaml",
]
  .map((p) => `--exclude=${p}`)
  .join(" ");

module.exports = {
  branches: ["main"],
  plugins: [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    [
      "@semantic-release/changelog",
      {
        changelogFile: "CHANGELOG.md",
      },
    ],
    "@semantic-release/github",
    [
      "@semantic-release/npm",
      {
        npmPublish: false,
      },
    ],
    [
      "@semantic-release/git",
      {
        assets: ["CHANGELOG.md"],
        message: "chore(release): ${nextRelease.version} [skip ci]",
      },
    ],
  ],
};
