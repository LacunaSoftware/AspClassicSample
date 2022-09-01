using Lacuna.Pki;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
using WebApplication1.Models;
using WebApplication1.Service;

namespace WebApplication1.Controllers
{
    public class HomeController : Controller
    {

        [HttpGet]
        public IActionResult Index()
        {

            var nonceStore = Util.GetNonceStore();


            var certAuth = new PKCertificateAuthentication(nonceStore);


            var nonce = certAuth.Start();

            var model = new AuthenticationModel()
            {
                Nonce = nonce,
                DigestAlgorithm = PKCertificateAuthentication.DigestAlgorithm.Oid
            };

            var vr = TempData["ValidationResults"] as ValidationResults;
            if (vr != null && !vr.IsValid)
            {
                ModelState.AddModelError("", vr.ToString());
            }

            return Json(model);
        }

        [HttpPost]
        public IActionResult Index(AuthenticationModel model)
        {

            var nonceStore = Util.GetNonceStore();
            var certAuth = new PKCertificateAuthentication(nonceStore);
            PKCertificate certificate;
            var vr = certAuth.Complete(model.Nonce, model.Certificate, model.Signature, Util.GetTrustArbitrator(), out certificate);
           
            if (!vr.IsValid)
            {
                TempData["ValidationResults"] = vr;
                return Json("alguma coisa");
            }
            return Json("alguma coisa");
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}