FROM julia:1.10-bookworm

WORKDIR /app
COPY Project.toml .
RUN julia -e 'using Pkg; Pkg.instantiate()'
COPY src/ src/
EXPOSE 8083
CMD ["julia", "-e", "using LunarOptimization; println(\"Julia service ready\")"]
