"""
The **pcl_registration** library implements a plethora of point cloud
registration algorithms for both organized an unorganized (general purpose)
datasets.

http://docs.pointclouds.org/trunk/group__registration.html

## Exports

$(EXPORTS)
"""
module PCLRegistration

export AbstractRegistration, setTransformationEstimation,
    setCorrespondenceEstimation, setInputSource, getInputSource, setInputTarget,
    getInputTarget, setSearchMethodTarget, getSearchMethodTarget,
    hasConverged, align,
    IterativeClosestPoint, setMaximumIterations, setMaxCorrespondenceDistance

using DocStringExtensions
using LibPCL
using PCLCommon
using PCLKDTree
using PCLSampleConsensus
using PCLFeatures
using PCLSearch
using Cxx

const libpcl_registration = LibPCL.find_library_e("libpcl_registration")
try
    Libdl.dlopen(libpcl_registration, Libdl.RTLD_GLOBAL)
catch e
    warn("You might need to set DYLD_LIBRARY_PATH to load dependencies proeprty.")
    rethrow(e)
end

cxx"""
#include <pcl/registration/icp.h>
"""

import PCLCommon: setInputCloud, getInputCloud

abstract type AbstractRegistration end

setTransformationEstimation(r::AbstractRegistration, te) =
    icxx"$(r.handle)->setTransformationEstimation($te);"
setCorrespondenceEstimation(r::AbstractRegistration, ce) =
    icxx"$(r.handle)->setCorrespondenceEstimation($ce);"
setInputCloud(r::AbstractRegistration, cloud::PointCloud) =
    icxx"$(r.handle)->setInputCloud($(cloud.handle));"
getInputCloud(r::AbstractRegistration) =
    PointCloud(icxx"$(r.handle)->getInputCloud();")
setInputSource(r::AbstractRegistration, cloud::PointCloud) =
    icxx"$(r.handle)->setInputSource($(cloud.handle));"
setInputSource(r::AbstractRegistration, cloud) =
    icxx"$(r.handle)->setInputSource($cloud);"
getInputSource(r::AbstractRegistration) =
    PointCloud(icxx"$(r.handle)->getInputSource();")
setInputTarget(r::AbstractRegistration, cloud::PointCloud) =
    icxx"$(r.handle)->setInputTarget($(cloud.handle));"
setInputTarget(r::AbstractRegistration, cloud) =
    icxx"$(r.handle)->setInputTarget($cloud);"
getInputTarget(r::AbstractRegistration) =
    PointCloud(icxx"$(r.handle)->getInputTarget();")
setSearchMethodTarget(r::AbstractRegistration, tree::PCLSearch.KdTree) =
    icxx"$(r.handle)->setSearchMethodTarget($(tree.handle));"
getSearchMethodTarget(r::AbstractRegistration) =
    PCLSearch.KdTree(icxx"$(r.handle)->getInputTarget();")
hasConverged(r::AbstractRegistration) = icxx"$(r.handle)->hasConverged();"
align(r::AbstractRegistration, cloud::PointCloud) =
    icxx"$(r.handle)->align(*$(cloud.handle));"


@defpcltype(IterativeClosestPoint{T1,T2} <: AbstractRegistration,
    "pcl::IterativeClosestPoint")
@defptrconstructor IterativeClosestPoint{T1,T2}() "pcl::IterativeClosestPoint"
@defconstructor IterativeClosestPointVal{T1,T2}() "pcl::IterativeClosestPoint"

for f in [:setMaximumIterations, :setMaxCorrespondenceDistance]
    body = Expr(:macrocall, Symbol("@icxx_str"), "\$(icp.handle)->$f(\$s);")
    @eval $f(icp::IterativeClosestPoint, s) = $body
end

end # module
