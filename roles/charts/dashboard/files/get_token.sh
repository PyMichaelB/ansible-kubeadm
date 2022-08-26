#!/bin/sh
echo $(kubectl -n kubernetes-dashboard create token admin-user)