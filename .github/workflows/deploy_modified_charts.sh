#!/bin/bash
echo $@
basedir=$(pwd)
for chart in "$@"; do
  echo "---------------------------------------"
  chart_name=$(echo "$chart" | cut -d"/" -f2 )
  echo "Chart Name: $chart_name"
  cd charts/$chart_name

  if [ -f ".no_ci" ]; then
      echo "No CI for this chart."
  else
      helm dependency build
      helm install $chart_name . --wait --timeout 300s 
      echo "$chart_name is installed"
      helm test $chart_name --logs 
  fi
  
  if [ $? -ne 0 ]; then
    echo "Error during deployment"
    exit 1
  else
    echo "Success ! "
    helm delete $chart_name || true 
  fi

  if [ $? -ne 0 ]; then
    echo "Error in lint of $chart_name"
    exit 1
  fi

  cd $basedir
done

