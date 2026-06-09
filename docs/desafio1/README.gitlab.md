# 🏗️ Desafio 1 — CI/CD da Landing Page (CondoCombat)

## 🎯 Objetivo

Criar uma pipeline de **Integração Contínua (CI)** e **Deploy Contínuo (CD)** para a **Landing Page** do CondoCombat, um site estático construído com [Astro](https://astro.build) + [TailwindCSS](https://tailwindcss.com).

A pipeline deve:

1. **Executar testes automatizados** (`vitest`)
2. **Fazer o build do projeto** (`astro build`)
3. **Fazer o deploy na Netlify** utilizando a **CLI oficial** da Netlify com token

Pipeline configurada para **GitLab CI/CD**.

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
- [ ] Repositório no [GitLab](https://gitlab.com)
- [ ] Netlify CLI instalada (opcional, para testes locais):

```bash
npm install -g netlify-cli
```

---

## 🔐 Variáveis de Ambiente (Secrets)

A pipeline precisa de duas variáveis de ambiente para fazer o deploy. Configure-as como **variáveis** no repositório:

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

## 🦊 GitLab CI/CD

Crie o arquivo `.gitlab-ci.yml` na **raiz do repositório**:

### `.gitlab-ci.yml`

```yaml
image: node:20

variables:
  NODE_VERSION: "20"

cache:
  key:
    files:
      - landing/package-lock.json
  paths:
    - landing/node_modules/

stages:
  - test
  - build
  - deploy

test-landing:
  stage: test
  script:
    - cd landing
    - npm ci
    - npm test
  artifacts:
    expire_in: 1 hour
    paths:
      - landing/node_modules/

build-landing:
  stage: build
  script:
    - cd landing
    - npm ci
    - npm run build
  artifacts:
    expire_in: 1 hour
    paths:
      - landing/dist/
  needs:
    - test-landing

deploy-landing:
  stage: deploy
  image: node:20
  script:
    - npm install -g netlify-cli
    - netlify deploy --dir=landing/dist --prod --auth=$NETLIFY_AUTH_TOKEN --site=$NETLIFY_SITE_ID
  needs:
    - build-landing
  only:
    - main
    - master
  environment:
    name: production
    url: https://$NETLIFY_SITE_NAME.netlify.app
```

### Explicação dos stages

| Stage     | Descrição                                     |
|-----------|-----------------------------------------------|
| `test`    | Instala deps e executa os testes do Vitest    |
| `build`   | Faz o build com `astro build` → gera `dist/`  |
| `deploy`  | Instala Netlify CLI e faz deploy para produção |

O `needs` garante a ordem: test → build → deploy.

### Configuração de Environment no GitLab

Para adicionar variáveis no GitLab:

1. Vá em **Settings** → **CI/CD** → **Variables**
2. Adicione:
   - `NETLIFY_AUTH_TOKEN` — marcada como **Masked**
   - `NETLIFY_SITE_ID` — marcada como **Masked**
   - `NETLIFY_SITE_NAME` — nome do seu site (ex: `condocombat-landing`)

> 💡 **Dica**: Use o `environment.url` com `https://$NETLIFY_SITE_NAME.netlify.app` para que o GitLab mostre um link direto para o site nos pipelines.

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
- [GitLab CI/CD — Documentação](https://docs.gitlab.com/ee/ci/)
- [Astro — Guia de deploy na Netlify](https://docs.astro.build/en/guides/deploy/netlify/)
- [CondoCombat — Landing Page](../../landing/)

---

## 💡 Dicas

1. **Monorepo**: O projeto CondoCombat é um monorepo com `landing/`, `frontend/` e `backend/`. A pipeline deve focar **apenas** na landing page. Use `only:changes` no GitLab CI/CD para evitar execuções desnecessárias.
2. **Netlify CLI**: Instale como dependência de desenvolvimento (`npm install -D netlify-cli`) para ter versão fixa no `package.json`.
3. **URL do site**: Após o deploy, o site estará disponível em `https://{site-name}.netlify.app`. Você pode configurar domínio personalizado depois.
4. **Teste em draft primeiro**: Faça o primeiro deploy sem `--prod` para verificar se está tudo certo antes de publicar.
5. **Logs**: Se o deploy falhar, verifique os logs da pipeline e da Netlify (Netlify → Deploys → clicar no deploy com problema).
