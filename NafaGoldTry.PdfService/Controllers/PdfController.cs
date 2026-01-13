using Microsoft.AspNetCore.Mvc;
using DinkToPdf;
using DinkToPdf.Contracts;

namespace NafaGoldTry.PdfService.Controllers
{
    [ApiController]
    [Route("pdf")]
    public class PdfController : ControllerBase
    {
        private readonly IConverter _converter;

        public PdfController(IConverter converter)
        {
            _converter = converter;
        }

        [HttpPost]
        public IActionResult Generate([FromBody] PdfRequest request)
        {
            if (request == null || string.IsNullOrWhiteSpace(request.Html))
                return BadRequest("HTML content missing");

            var document = new HtmlToPdfDocument
            {
                GlobalSettings = new GlobalSettings
                {
                    PaperSize = PaperKind.Letter,        // 🔥 MATCHES @page { size: Letter }
                    Orientation = Orientation.Portrait,

                    // 🔥 REMOVE ALL PRINTER MARGINS
                    Margins = new MarginSettings
                    {
                        Top = 0,
                        Bottom = 0,
                        Left = 0,
                        Right = 0
                    }
                },

                Objects =
                {
                    new ObjectSettings
                    {
                        HtmlContent = request.Html,

                        WebSettings = new WebSettings
                        {
                            DefaultEncoding = "utf-8",
                            LoadImages = true,
                            PrintMediaType = true
                        },

                        // 🔥 Disable wkhtmltopdf header/footer space
                        HeaderSettings = new HeaderSettings
                        {
                            Spacing = 0
                        },
                        FooterSettings = new FooterSettings
                        {
                            Spacing = 0
                        }
                    }
                }
            };

            var pdf = _converter.Convert(document);

            return File(pdf, "application/pdf", "document.pdf");
        }
    }

    public class PdfRequest
    {
        public string Html { get; set; }
    }
}
