FROM node:18.12-bullseye-slim AS node

#### runtime ####
FROM ubuntu:jammy-20221101 AS runtime

COPY --from=node /usr/local/include/ /usr/local/include/
COPY --from=node /usr/local/lib/ /usr/local/lib/
COPY --from=node /usr/local/bin/ /usr/local/bin/

ENTRYPOINT [ "/bin/bash" ]
