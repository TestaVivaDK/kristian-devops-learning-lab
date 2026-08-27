# Kubernetes Debug Notes

## 1. Invalid Image Tag

- Incident: Changed the Deployment image from `kristian-web:1.0.0` to an invalid tag.
- Location: `kubernetes/deployment.yaml` on the `image:` line under the `nginx` container.
- Symptoms: New pods did not become Ready and showed `ErrImagePull` or `ImagePullBackOff`.
- Evidence: `kubectl get pods -n kristian-lab` showed failed pod status, and the Events section in `kubectl describe pod -n kristian-lab` showed repeated failed image pull attempts.
- Root cause: Kubernetes was told to run an image tag that did not exist in the `kind` cluster image store.
- Fix: Restore the correct image value, `kristian-web:1.0.0`, and apply the manifests again.
- Prevention: Use pinned, verified image tags and double-check the Deployment image before applying changes.

## 2. Broken Service Selector

- Incident: Changed the Service selector so it no longer matched the pod labels.
- Location: `kubernetes/service.yaml` under `spec.selector.app.kubernetes.io/name`.
- Symptoms: The pods stayed `Running` and `Ready`, but the Service had no endpoints and traffic through it failed.
- Evidence: `kubectl get endpointslice -n kristian-lab` showed `<unset>` for ports and endpoints, and `kubectl describe service learning-web -n kristian-lab` showed the wrong selector with empty endpoints.
- Root cause: The Service selector did not match the labels on the pods.
- Fix: Restore the selector to `app.kubernetes.io/name=learning-web` and apply the manifests again.
- Prevention: Keep Service selectors and pod labels consistent and verify endpoints after Service changes.

## 3. Broken Readiness Path

- Incident: Changed the readiness probe path to a path that did not exist.
- Location: `kubernetes/deployment.yaml` under `readinessProbe.httpGet.path`.
- Symptoms: A new pod appeared as `Running` but not `Ready`, and the rollout stopped partway through.
- Evidence: `kubectl get pods -n kristian-lab` showed the new pod as `0/1 Running`, and `kubectl describe pod -n kristian-lab` showed `Readiness probe failed: HTTP probe failed with statuscode: 404`.
- Root cause: The readiness probe checked the wrong path, so Kubernetes did not consider the pod ready for traffic.
- Fix: Restore the readiness path to `/healthz` and apply the manifests again.
- Prevention: Point readiness probes at a real endpoint and verify the path with `curl` before changing the Deployment.

## Extra: How to Check the Setup Is Healthy

- Check pods: `kubectl get pods -n kristian-lab`
- Check rollout: `kubectl rollout status deployment/learning-web -n kristian-lab`
- Check Service backends: `kubectl get endpointslice -n kristian-lab`
- Check the site: `curl http://localhost:8080`
- Check the health endpoint: `curl http://localhost:8080/healthz`

Healthy result for this lab:

- Two pods are `1/1 Running`.
- The rollout completes successfully.
- The Service has real endpoints, not `<unset>`.
- `/` returns the custom page.
- `/healthz` returns `ok`.
