@echo off
set prefix="cloudgenuser"
for /f %%i in ('npm pkg get name') do set name=%%i
for /f %%i in ('npm pkg get version') do set tag=%%i
set name_docker="%prefix%/%name%:%tag%"
docker build --build-arg OTEL_EXPORTER_OTLP_ENDPOINT=http://jaeger:4318 --build-arg OTEL_EXPORTER_OTLP_PROTOCOL=http/json --build-arg OTEL_SERVICE_NAME=telemetry --build-arg OTEL_NODE_RESOURCE_DETECTORS=env,host,os,process,container -t %name_docker% --no-cache .