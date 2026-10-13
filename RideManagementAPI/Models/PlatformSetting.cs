using System.ComponentModel.DataAnnotations;

namespace RideManagementAPI.Models
{
    public class PlatformSetting
    {
        public int Id { get; set; }

        [Required]
        public string Key { get; set; } = "";

        [Required]
        public string Value { get; set; } = "";

        public bool IsActive { get; set; } = true;
    }
}