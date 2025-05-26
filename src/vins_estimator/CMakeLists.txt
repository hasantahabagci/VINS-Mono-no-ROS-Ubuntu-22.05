cmake_minimum_required(VERSION 2.8.3)
project(vins_estimator)

set(CMAKE_BUILD_TYPE "Release")
set(CMAKE_CXX_FLAGS "-std=c++14")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -Wall -g -pthread -fopenmp")

# Camera model includes
include_directories(${CMAKE_SOURCE_DIR}/../camera_model/include)

find_package(CUDA  REQUIRED)
include_directories("${CUDA_INCLUDE_DIRS}")

# OpenCV
find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})

# Ceres Solver
find_package(Ceres REQUIRED)
include_directories(${CERES_INCLUDE_DIRS})

# Eigen
include_directories(/usr/include/eigen3)

# Boost
find_package(Boost REQUIRED COMPONENTS filesystem program_options system)
include_directories(${Boost_INCLUDE_DIRS})

# Pangolin
find_package(Pangolin REQUIRED)
include_directories(${Pangolin_INCLUDE_DIRS})

add_executable(vins_estimator
    src/estimator_node.cpp
    src/parameters.cpp
    src/estimator.cpp
    src/feature_manager.cpp
    src/factor/pose_local_parameterization.cpp
    src/factor/projection_factor.cpp
    src/factor/marginalization_factor.cpp
    src/utility/utility.cpp
    src/utility/visualization.cpp
    src/initial/solve_5pts.cpp
    src/initial/initial_aligment.cpp
    src/initial/initial_sfm.cpp
    src/initial/initial_ex_rotation.cpp
    src/loop-closure/ThirdParty/DBoW/BowVector.cpp
    src/loop-closure/ThirdParty/DBoW/FBrief.cpp
    src/loop-closure/ThirdParty/DBoW/FeatureVector.cpp
    src/loop-closure/ThirdParty/DBoW/QueryResults.cpp
    src/loop-closure/ThirdParty/DBoW/ScoringObject.cpp
    src/loop-closure/ThirdParty/DUtils/Random.cpp
    src/loop-closure/ThirdParty/DUtils/Timestamp.cpp
    src/loop-closure/ThirdParty/DVision/BRIEF.cpp
    src/loop-closure/ThirdParty/VocabularyBinary.cpp
    src/loop-closure/loop_closure.cpp
    src/loop-closure/keyframe.cpp
    src/loop-closure/keyframe_database.cpp
    src/feature_tracker/feature_tracker.cpp 
    ../camera_model/src/chessboard/Chessboard.cc
    ../camera_model/src/calib/CameraCalibration.cc
    ../camera_model/src/camera_models/Camera.cc
    ../camera_model/src/camera_models/CameraFactory.cc
    ../camera_model/src/camera_models/CostFunctionFactory.cc
    ../camera_model/src/camera_models/PinholeCamera.cc
    ../camera_model/src/camera_models/CataCamera.cc
    ../camera_model/src/camera_models/EquidistantCamera.cc
    ../camera_model/src/camera_models/ScaramuzzaCamera.cc
    ../camera_model/src/sparse_graph/Transform.cc
    ../camera_model/src/gpl/gpl.cc
    ../camera_model/src/gpl/EigenQuaternionParameterization.cc
)

target_link_libraries(vins_estimator 
    ${OpenCV_LIBS}
    ${CERES_LIBRARIES}
    ${Boost_LIBRARIES}
    ${Pangolin_LIBRARIES}
)

