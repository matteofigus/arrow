# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

# https://github.com/autobrew/homebrew-core/blob/master/Formula/apache-arrow.rb
class ApacheArrow < Formula
  desc "Columnar in-memory analytics layer designed to accelerate big data"
  homepage "https://arrow.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=arrow/arrow-0.15.0.9000/apache-arrow-0.15.0.9000.tar.gz"
  sha256 "9948ddb6d4798b51552d0dca3252dd6e3a7d0f9702714fc6f5a1b59397ce1d28"
  head "https://github.com/apache/arrow.git"

  bottle do
    cellar :any
    sha256 "a55211ba6f464681b7ca1b48defdad9cfbe1cf6fad8ff9ec875dc5a3c8f3c5ed" => :el_capitan_or_later
    root_url "https://autobrew.github.io/bottles"
  end

  depends_on "cmake" => :build
  depends_on "flatbuffers" => :build
  depends_on "aws-sdk-cpp"
  depends_on "boost"
  depends_on "double-conversion"
  depends_on "lz4"
  depends_on "snappy"
  depends_on "thrift"

  def install
    ENV.cxx11
    args = %W[
      -DARROW_PARQUET=ON
      -DARROW_PLASMA=OFF
      -DARROW_HDFS=OFF
      -DARROW_BUILD_TESTS=OFF
      -DARROW_TEST_LINKAGE="static"
      -DARROW_BUILD_SHARED=OFF
      -DARROW_JEMALLOC=OFF
      -DARROW_WITH_BROTLI=OFF
      -DARROW_USE_GLOG=OFF
      -DARROW_PYTHON=OFF
      -DARROW_S3=ON
      -DARROW_WITH_ZSTD=OFF
      -DARROW_WITH_SNAPPY=ON
      -DARROW_BUILD_UTILITIES=ON
      -DPARQUET_BUILD_EXECUTABLES=ON
      -DFLATBUFFERS_HOME=#{Formula["flatbuffers"].prefix}
      -DLZ4_HOME=#{Formula["lz4"].prefix}
      -DTHRIFT_HOME=#{Formula["thrift"].prefix}
    ]

    mkdir "build"
    cd "build" do
      system "cmake", "../cpp", *std_cmake_args, *args
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include "arrow/api.h"
      int main(void) {
        arrow::int64();
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-std=c++11", "-I#{include}", "-L#{lib}", "-larrow", "-lparquet", "-lthrift", "-llz4", "-lboost_system", "-lboost_filesystem", "-lboost_regex", "-ldouble-conversion", "-lsnappy", "-o", "test"
    system "./test"
  end
end
