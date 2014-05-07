#!/bin/bash
mkfontscale &&
mkfontdir &&
fc-cache -fv ~/.fonts
