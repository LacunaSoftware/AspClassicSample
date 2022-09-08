using Lacuna.Pki;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
using AspClassicService.Models;
using AspClassicService.Services;
namespace AspClassicService.Controllers
{
	public class HomeController : Controller
	{
		private readonly IWebHostEnvironment _hostingEnvironment;

		public HomeController(IWebHostEnvironment _hostingEnvironment)
		{
			this._hostingEnvironment = _hostingEnvironment;
		}

		[HttpGet]
		public ActionResult Index()
		{
			var nonceStore = Util.GetNonceStore(_hostingEnvironment);

			var certAuth = new PKCertificateAuthentication(nonceStore);

			var nonce = certAuth.Start();

			var model = new AuthenticationModel()
			{
				Nonce = nonce,
				DigestAlgorithm = PKCertificateAuthentication.DigestAlgorithm.Oid
			};

			return Json(model);
		}

		[HttpPost]
		public ActionResult Index([FromBody] AuthenticationModel model)
		{
			var nonceStore = Util.GetNonceStore(_hostingEnvironment);

			var certAuth = new PKCertificateAuthentication(nonceStore);
			PKCertificate certificate;
			var vr = certAuth.Complete(model.Nonce, model.Certificate, model.Signature, Util.GetTrustArbitrator(), out certificate);

			if (!vr.IsValid)
			{
				return UnprocessableEntity(new ValidationErrorModel()
				{
					ValidationText = vr.ToString()
				});
			}

			var userCert = PKCertificate.Decode(model.Certificate);
			return Ok(new AuthenticationInfoModel()
			{
				SubjectName = userCert.SubjectName.CommonName,
				Cpf = userCert.PkiBrazil.CpfFormatted,
				Cnpj = userCert.PkiBrazil.CnpjFormatted,
			});
		}
	}
}
