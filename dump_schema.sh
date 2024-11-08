#!/bin/bash

mkdir -p ./data
supabase db dump --linked -f ./data/schema.sql --schema public

