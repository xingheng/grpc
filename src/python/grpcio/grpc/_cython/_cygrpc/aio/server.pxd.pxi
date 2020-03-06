# Copyright 2019 The gRPC Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

cdef class _HandlerCallDetails:
    cdef readonly str method
    cdef readonly tuple invocation_metadata


cdef class RPCState(GrpcCallWrapper):
    cdef grpc_call_details details
    cdef grpc_metadata_array request_metadata
    cdef AioServer server
    # NOTE(lidiz) Under certain corner case, receiving the client close
    # operation won't immediately fail ongoing RECV_MESSAGE operations. Here I
    # added a flag to workaround this unexpected behavior.
    cdef bint client_closed
    cdef object abort_exception
    cdef bint metadata_sent
    cdef bint status_sent
    cdef grpc_status_code status_code
    cdef str status_details
    cdef tuple trailing_metadata
    cdef object compression_algorithm
    cdef bint disable_next_compression

    cdef bytes method(self)
    cdef tuple invocation_metadata(self)
    cdef void raise_for_termination(self) except *
    cdef int get_write_flag(self)
    cdef Operation create_send_initial_metadata_op_if_not_sent(self)


cdef enum AioServerStatus:
    AIO_SERVER_STATUS_UNKNOWN
    AIO_SERVER_STATUS_READY
    AIO_SERVER_STATUS_RUNNING
    AIO_SERVER_STATUS_STOPPED
    AIO_SERVER_STATUS_STOPPING


cdef class AioServer:
    cdef Server _server
    # cdef CallbackCompletionQueue _cq
    cdef BackgroundCompletionQueue _cq
    cdef list _generic_handlers
    cdef AioServerStatus _status
    cdef object _loop  # asyncio.EventLoop
    cdef object _serving_task  # asyncio.Task
    cdef object _shutdown_lock  # asyncio.Lock
    cdef object _shutdown_completed  # asyncio.Future
    cdef CallbackWrapper _shutdown_callback_wrapper
    cdef object _crash_exception  # Exception
    cdef set _ongoing_rpc_tasks
    cdef tuple _interceptors
