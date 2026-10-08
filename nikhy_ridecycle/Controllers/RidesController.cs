using Microsoft.AspNetCore.Mvc;
using Nikhy_demo.DTOs;
using Nikhy_demo.Enums;
using Nikhy_demo.Services;

namespace Nikhy_demo.Controllers
{
    [ApiController]
    [Route("api/rides")]
    public class RidesController : ControllerBase
    {
        private readonly IRideService _rideService;

        public RidesController(
            IRideService rideService)
        {
            _rideService = rideService;
        }


        // =========================================================
        // DAY 1
        // CREATE BOOKING
        // POST: api/rides
        // =========================================================

        [HttpPost]
        public async Task<IActionResult> CreateRide(
            [FromBody] CreateRideRequest request)
        {
            try
            {
                var result =
                    await _rideService.CreateRideAsync(request);

                return CreatedAtAction(
                    nameof(GetRideById),
                    new { rideId = result.RideId },
                    result);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new
                {
                    message = ex.Message
                });
            }
        }


        // =========================================================
        // GET RIDE DETAILS
        // GET: api/rides/{rideId}
        // =========================================================

        [HttpGet("{rideId:long}")]
        public async Task<IActionResult> GetRideById(
            long rideId)
        {
            var result =
                await _rideService.GetRideByIdAsync(rideId);

            if (result == null)
            {
                return NotFound(new
                {
                    message = "Ride not found."
                });
            }

            return Ok(result);
        }


        // =========================================================
        // DAY 2
        // ACCEPT RIDE
        // POST: api/rides/{rideId}/accept
        // =========================================================

        [HttpPost("{rideId:long}/accept")]
        public async Task<IActionResult> AcceptRide(
            long rideId,
            [FromQuery] long driverId)
        {
            try
            {
                var result =
                    await _rideService.AcceptRideAsync(
                        rideId,
                        driverId);

                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new
                {
                    message = ex.Message
                });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new
                {
                    message = ex.Message
                });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new
                {
                    message = ex.Message
                });
            }
        }


        // =========================================================
        // STATUS UPDATE
        // PATCH: api/rides/{rideId}/status
        // =========================================================

        [HttpPatch("{rideId:long}/status")]
        public async Task<IActionResult> UpdateStatus(
            long rideId,
            [FromBody] UpdateRideStatusRequest request)
        {
            try
            {
                var result =
                    await _rideService.UpdateStatusAsync(
                        rideId,
                        request.Status);

                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new
                {
                    message = ex.Message
                });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new
                {
                    message = ex.Message
                });
            }
        }


        // =========================================================
        // RIDER ARRIVING
        // POST: api/rides/{rideId}/arriving
        // =========================================================

        [HttpPost("{rideId:long}/arriving")]
        public async Task<IActionResult> RiderArriving(
            long rideId)
        {
            try
            {
                var result =
                    await _rideService.RiderArrivingAsync(
                        rideId);

                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new
                {
                    message = ex.Message
                });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new
                {
                    message = ex.Message
                });
            }
        }


        // =========================================================
        // ARRIVED
        // POST: api/rides/{rideId}/arrived
        // =========================================================

        [HttpPost("{rideId:long}/arrived")]
        public async Task<IActionResult> Arrived(
            long rideId)
        {
            try
            {
                var result =
                    await _rideService.ArrivedAsync(
                        rideId);

                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new
                {
                    message = ex.Message
                });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new
                {
                    message = ex.Message
                });
            }
        }


        // =========================================================
        // DAY 3
        // START RIDE
        // POST: api/rides/{rideId}/start
        // =========================================================

        [HttpPost("{rideId:long}/start")]
        public async Task<IActionResult> StartRide(
            long rideId)
        {
            try
            {
                var result =
                    await _rideService.StartRideAsync(
                        rideId);

                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new
                {
                    message = ex.Message
                });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new
                {
                    message = ex.Message
                });
            }
        }


        // =========================================================
        // COMPLETE RIDE
        // POST: api/rides/{rideId}/complete
        // =========================================================

        [HttpPost("{rideId:long}/complete")]
        public async Task<IActionResult> CompleteRide(
            long rideId)
        {
            try
            {
                var result =
                    await _rideService.CompleteRideAsync(
                        rideId);

                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new
                {
                    message = ex.Message
                });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new
                {
                    message = ex.Message
                });
            }
        }


        // =========================================================
        // CANCEL RIDE
        // POST: api/rides/{rideId}/cancel
        // =========================================================

        [HttpPost("{rideId:long}/cancel")]
        public async Task<IActionResult> CancelRide(
            long rideId,
            [FromBody] CancelRideRequest request)
        {
            try
            {
                var result =
                    await _rideService.CancelRideAsync(
                        rideId,
                        request);

                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new
                {
                    message = ex.Message
                });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new
                {
                    message = ex.Message
                });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new
                {
                    message = ex.Message
                });
            }
        }


        // =========================================================
        // RIDE HISTORY
        // GET: api/rides/history
        // =========================================================

        [HttpGet("history")]
        public async Task<IActionResult> GetHistory(
            [FromQuery] long? passengerId,
            [FromQuery] long? driverId,
            [FromQuery] RideStatus? status,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10)
        {
            var result =
                await _rideService.GetHistoryAsync(
                    passengerId,
                    driverId,
                    status,
                    page,
                    pageSize);

            return Ok(new
            {
                page,
                pageSize,
                count = result.Count,
                data = result
            });
        }
    }
}