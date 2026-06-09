# 🏗️ Desafio 1 — CI/CD da Landing Page (CondoCombat)

## 🎯 Objetivo

Criar uma pipeline de **Integração Contínua (CI)** e **Deploy Contínuo (CD)** para a **Landing Page** do CondoCombat, um site estático construído com [Astro](https://astro.build) + [TailwindCSS](https://tailwindcss.com).

A pipeline deve:

1. **Executar testes automatizados** (`vitest`)
2. **Fazer o build do projeto** (`astro build`)
3. **Fazer o deploy na Netlify** utilizando a **CLI oficial** da Netlify com token

Pipeline configurada para **GitHub Actions**.

---

## 📦 Sobre o Projeto

### Landing Page (`landing/`)

| Item            | Detalhe                        |
|-----------------|--------------------------------|
| Framework       | Astro 5 + TailwindCSS 3        |
| Pasta de build  | `dist/`                        |
| Testes          | Vitest                         |
| Comando build   | `npm run build` → `astro build`|
| Comando teste   | `npm test` → `vitest run`      |
| Porta dev       | `localhost:4321`               |

```bash
# Instalar dependências
npm install

# Rodar testes
npm test

# Build local
npm run build

# Preview do build
npm run preview
```

---

## 📋 Pré-requisitos

- [ ] Conta na [Netlify](https://app.netlify.com/signup)
- [ ] Repositório no [GitHub](https://github.com)
- [ ] Netlify CLI instalada (opcional, para testes locais):

```bash
npm install -g netlify-cli
```

---

## 🔐 Variáveis de Ambiente (Secrets)

A pipeline precisa de duas variáveis de ambiente para fazer o deploy. Configure-as como **secrets** no repositório:

| Variável              | Descrição                                      | Onde conseguir                                  |
|-----------------------|------------------------------------------------|-------------------------------------------------|
| `NETLIFY_AUTH_TOKEN`  | Token de autenticação da Netlify    | Netlify → User Settings → Personal access tokens |
| `NETLIFY_SITE_ID`     | ID do site criado na Netlify                   | Netlify → Site settings → General → Site ID      |
| `NETLIFY_SITE_NAME`   | Nome do site (slug) — usado no deploy via CLI  | Netlify → Site settings → General → Site name    |

### Como gerar o `NETLIFY_AUTH_TOKEN`

1. Acesse [app.netlify.com](https://app.netlify.com)
2. Vá em **User Settings** (foto do canto superior direito) → **Applications**
3. Em **Personal access tokens**, clique em **New access token**
4. Dê um nome (ex: `ci-cd-condocombat`) e copie o token gerado
5. Adicione como secret no repositório com o nome `NETLIFY_AUTH_TOKEN`

### Como obter o `NETLIFY_SITE_ID`

1. No Netlify, vá em **Sites** → selecione o site criado
2. Vá em **Site settings** → **General** → **Site details**
3. Copie o **Site ID** (é um UUID, ex: `12345678-9abc-def0-1234-56789abcdef0`)
4. Adicione como secret no repositório com o nome `NETLIFY_SITE_ID`

> 💡 **Dica**: Você pode criar o site manualmente pelo dashboard da Netlify ou via CLI com `netlify sites:create`.

---

## 🌐 Configuração `netlify.toml`

Crie o arquivo `netlify.toml` na raiz da landing page (`landing/netlify.toml`):

```toml
[build]
  command = "npm run build"
  publish = "dist"

[build.environment]
  NODE_VERSION = "20"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

> ℹ️ Este arquivo informa à Netlify qual comando executar e qual pasta publicar. Ele é opcional, mas ajuda na consistência entre deploys locais e via pipeline.

---

## 🚀 Deploy com Netlify CLI

O deploy é feito com a `netlify-cli` dentro da pipeline:

```bash
npm install -g netlify-cli
netlify deploy --dir=dist --prod --auth=$NETLIFY_AUTH_TOKEN --site=$NETLIFY_SITE_ID
```

| Flag      | Significado                                        |
|-----------|----------------------------------------------------|
| `--dir`   | Diretório com os arquivos do build (`dist`)        |
| `--prod`  | Deploy direto para produção (sem draft)            |
| `--auth`  | Token de autenticação                              |
| `--site`  | ID do site na Netlify                              |

---

## 🐙 GitHub Actions

Crie o diretório `.github/workflows/` na **raiz do repositório** (não dentro de `landing/`) e adicione o arquivo:

### `deploy-landing.yml`

```yaml
name: Deploy Landing Page

on:
  push:
    branches: [main, master]
    paths:
      - 'landing/**'
      - '.github/workflows/deploy-landing.yml'
  workflow_dispatch:

env:
  NODE_VERSION: '20'

jobs:
  ci:
    name: CI — Test & Build
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./landing

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: ./landing/package-lock.json

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test

      - name: Build
        run: npm run build

      - name: Upload build artifact
        uses: actions/upload-artifact@v4
        with:
          name: landing-dist
          path: landing/dist/

  cd:
    name: CD — Deploy to Netlify
    needs: ci
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}

      - name: Download build artifact
        uses: actions/download-artifact@v4
        with:
          name: landing-dist
          path: landing/dist/

      - name: Install Netlify CLI
        run: npm install -g netlify-cli

      - name: Deploy to Netlify
        run: |
          netlify deploy \
            --dir=landing/dist \
            --prod \
            --auth=${{ secrets.NETLIFY_AUTH_TOKEN }} \
            --site=${{ secrets.NETLIFY_SITE_ID }}
```

### Explicação

| Job   | Responsabilidade                                           |
|-------|------------------------------------------------------------|
| `ci`  | Instalar deps → rodar testes → build → salvar artefato     |
| `cd`  | Baixar artefato do build → instalar CLI → deploy na Netlify |

O job `cd` só executa se o `ci` passar (`needs: ci`).

### Gatilhos (`on.push.paths`)

A pipeline é acionada apenas quando há mudanças em:

- `landing/**` — qualquer arquivo da landing page
- `.github/workflows/deploy-landing.yml` — o próprio workflow

Isso evita rodar a pipeline quando outras partes do monorepo (backend, frontend) são alteradas.

---

## 🧪 Validação local antes de subir

Antes de commitar, teste tudo localmente:

```bash
# 1. Testes
cd landing && npm test

# 2. Build
npm run build

# 3. Testar deploy (draft) localmente com a CLI
netlify deploy --dir=dist --auth=$NETLIFY_AUTH_TOKEN --site=$NETLIFY_SITE_ID

# 4. Se o draft estiver OK, faça o deploy para produção
netlify deploy --dir=dist --prod --auth=$NETLIFY_AUTH_TOKEN --site=$NETLIFY_SITE_ID

# 5. (Opcional) Simular a pipeline completo localmente com act
#    https://github.com/nektos/act
act --job ci --container-architecture linux/amd64
```

---

## ✅ Critérios de Avaliação

| Critério                           | Peso | Descrição                                          |
|------------------------------------|------|----------------------------------------------------|
| Testes passando na pipeline        | 25%  | `vitest run` executa sem erros                     |
| Build concluído com sucesso        | 20%  | `astro build` gera a pasta `dist/`                 |
| Deploy publicado na Netlify        | 30%  | Site acessível via URL pública                     |
| Pipeline automatizada (CI/CD)      | 15%  | Pipeline roda sozinha no push para `main`          |
| Organização e clareza do código    | 10%  | YAML limpo, boas práticas, secrets bem configurados|

---

## 📚 Referências

- [Netlify CLI — Comando deploy](https://github.com/netlify/cli/blob/main/docs/commands/deploy.md)
- [GitHub Actions — Documentação](https://docs.github.com/en/actions)
- [act — Execute GitHub Actions localmente](https://github.com/nektos/act)
- [Astro — Guia de deploy na Netlify](https://docs.astro.build/en/guides/deploy/netlify/)
- [CondoCombat — Landing Page](../../landing/)

---

## 💡 Dicas

1. **Monorepo**: O projeto CondoCombat é um monorepo com `landing/`, `frontend/` e `backend/`. A pipeline deve focar **apenas** na landing page. Use `paths` no GitHub Actions para evitar execuções desnecessárias.
2. **Netlify CLI**: Instale como dependência de desenvolvimento (`npm install -D netlify-cli`) para ter versão fixa no `package.json`.
3. **URL do site**: Após o deploy, o site estará disponível em `https://{site-name}.netlify.app`. Você pode configurar domínio personalizado depois.
4. **Teste em draft primeiro**: Faça o primeiro deploy sem `--prod` para verificar se está tudo certo antes de publicar.
5. **Logs**: Se o deploy falhar, verifique os logs da pipeline e da Netlify (Netlify → Deploys → clicar no deploy com problema).
