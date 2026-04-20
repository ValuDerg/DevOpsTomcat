# DevOps Pipeline – Setup Guide

## Repository Layout

Place both files at the root of your GitHub repository:

```
your-repo/
├── docker-compose.yml   ← defines Jenkins + Tomcat
├── Jenkinsfile          ← pipeline logic
└── index.html           ← (or whatever your web app files are)
```

Tomcat serves everything inside `/home/valu/Documents/devops-webpage` as the ROOT
webapp, so your web files must also live at the root of the repo (or in a
subdirectory you adjust the mount path for).

---

## One-time Host Setup

### 1. Create the deploy directory

```bash
mkdir -p /home/valu/Documents/devops-webpage
```

### 2. Start the stack for the first time

```bash
cd /path/to/your/repo
docker compose up -d
```

Jenkins is now at http://<pi-ip>:8080
Tomcat is now at http://<pi-ip>:8888

### 3. Unlock Jenkins (first run only)

```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Paste that password into the Jenkins UI, install suggested plugins, and create
your admin user. Skip this step on subsequent runs (data is persisted in the
`jenkins_home` Docker volume).

---

## Jenkins Job Configuration

1. **New Item → Pipeline**
2. Under *Pipeline*, set *Definition* to **Pipeline script from SCM**
3. SCM: **Git**
4. Repository URL: your GitHub repo URL
5. Branch: `*/main` (or your branch)
6. Script Path: `Jenkinsfile`
7. Save, then **Build Now** to test.

For automatic triggering, add a GitHub webhook pointing to:

```
http://<pi-ip>:8080/github-webhook/
```

(requires the *GitHub plugin*, included in suggested plugins)

---

## How the Pipeline Works

```
GitHub repo
     │
     │  (1) Jenkins pulls latest files via git
     ▼
/home/valu/Documents/devops-webpage   ← host directory
     │
     │  (2) Docker removes & recreates both containers
     │
     ├── Jenkins container  (re-created, picks up new compose config if any)
     │
     └── Tomcat container
              │  volume mount
              └─▶ /usr/local/tomcat/webapps/ROOT
                       │
                       └─▶ serves updated web app on :8888
```

**Stage 1 – Pull latest code**
Jenkins runs `git pull` (or `git clone` on first run) directly into
`/home/valu/Documents/devops-webpage` on the host. Because Jenkins mounts
`/var/run/docker.sock` and the Docker CLI binary, it can issue host-level
`git` and `docker` commands.

**Stage 2 – Redeploy containers**
Jenkins calls `docker compose up -d` with the `docker-compose.yml` that was
checked out alongside the Jenkinsfile. Both containers are stopped, removed,
and recreated. The Tomcat container immediately mounts the updated host
directory and begins serving the new content.

---

## Notes & Gotchas

- **git on host**: The `git` binary must be available on the host (the Jenkins
  container runs git commands via the Docker socket against the host filesystem).
  Install with `sudo apt install git` on the Pi if needed.

- **Permissions**: Jenkins runs as `root` inside the container (set in
  docker-compose.yml) so it can write to the host deploy directory and call
  Docker. Scope this down if your security requirements demand it.

- **Port mapping**: Jenkins → 8080, Tomcat → 8888. Change `8888:8080` in
  docker-compose.yml if you want a different host port.

- **REPO_URL**: Edit the `REPO_URL` environment variable in the Jenkinsfile to
  point to your actual GitHub repository before running the pipeline.

- **Private repos**: Add a Jenkins credential (SSH key or personal access
  token) and reference it in the SCM config under *Credentials*.
