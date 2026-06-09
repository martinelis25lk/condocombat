# 🏗️ Desafio 1 — CI/CD da Landing Page (CondoCombat)

## 🎯 Objetivo

Criar uma pipeline de **Integração Contínua (CI)** e **Deploy Contínuo (CD)** para a **Landing Page** do CondoCombat, um site estático construído com [Astro](https://astro.build) + [TailwindCSS](https://tailwindcss.com).

A pipeline deve:

1. **Executar testes automatizados** (`vitest`)
2. **Fazer o build do projeto** (`astro build`)
3. **Fazer o deploy na Netlify** utilizando a **CLI oficial** da Netlify com token

Escolha a plataforma desejada abaixo:

| Plataforma | Arquivo |
|-----------|---------|
| 🐙 GitHub Actions | [`README.github.md`](./README.github.md) |
| 🦊 GitLab CI/CD | [`README.gitlab.md`](./README.gitlab.md) |

---

## 📚 Referências

- [Netlify CLI — Comando deploy](https://github.com/netlify/cli/blob/main/docs/commands/deploy.md)
- [GitHub Actions — Documentação](https://docs.github.com/en/actions)
- [GitLab CI/CD — Documentação](https://docs.gitlab.com/ee/ci/)
- [Astro — Guia de deploy na Netlify](https://docs.astro.build/en/guides/deploy/netlify/)
- [CondoCombat — Landing Page](../../landing/)
