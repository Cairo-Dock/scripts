#!/bin/bash
for RLS in stable testing unstable; do
	for i in incoming/*\~"$RLS"_*.changes; do
		reprepro --ignore=missingfile -Vb . include $RLS $i;
	done;
done
for RLS in stable testing unstable; do
	for i in incoming/*\~"$RLS"_*.deb; do
		reprepro -Vb . includedeb $RLS $i;
	done;
done
