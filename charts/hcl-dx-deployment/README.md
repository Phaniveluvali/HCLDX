# hcl-dx-deployment Helm Charts

This Helm Chart contains the deployment of HCL Digital Experience.

Please visit [HCL Digital Experience - Helm based deployments](https://opensource.hcltechsw.com/digital-experience/latest/platform/kubernetes/overview/) for detailed installation instructions.

# HCL Digital Experience Sizing

## Minimal - `values.yaml` (default)

- The `values.yaml` file includes the default values for the minimal resource requests required for DX.

## Small - `value-samples/small-config-values.yaml`

- The `small-config-values.yaml` file contains increased resource requests of specific pods that help handling more load in HCL Digital Experience rendering scenarios.
- HCL Digital Experience Rendering performance tests are executed with 1000 users concurrent load on components like WCM, DAM and portlets with `small-config-values.yaml` file.
- For more information about the performance test results of this please check out in the help center documentation [DX-Rendering-Small-Config-Results]
(https://opensource.hcltechsw.com/digital-experience/latest/get_started/plan_deployment/container_deployment/rm_container/dx_performance_small_cfg/)