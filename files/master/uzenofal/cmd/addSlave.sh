#!/bin/bash
echo "[LOG] Slave added to master list. IP: ${1}"
echo "${1}" >> /uzenofal/slaveIPs
