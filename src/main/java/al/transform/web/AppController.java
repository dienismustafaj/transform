package al.transform.web;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.LocaleResolver;

import java.util.Locale;

@Controller
public class AppController {
    @Autowired
    private LocaleResolver localeResolver;

    @GetMapping("/")
    public String handleRequest(@RequestParam(name = "lang", required = false) String lang, HttpServletRequest request, HttpServletResponse response) {
        if (lang == null || (!lang.equalsIgnoreCase("sq")&& !lang.equalsIgnoreCase("en") && !lang.equalsIgnoreCase("it"))) {
            localeResolver.setLocale(request, response, new Locale("sq"));
        }
        return "index"; // Return the name of the Thymeleaf template
    }
}
