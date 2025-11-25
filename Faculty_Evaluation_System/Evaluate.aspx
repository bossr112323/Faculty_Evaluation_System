<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Evaluate.aspx.vb" Inherits="Faculty_Evaluation_System.Evaluate" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Evaluate Faculty - Faculty Evaluation System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <style>
        :root {
            --primary: #1a3a8f;
            --primary-light: #2a4aaf;
            --primary-dark: #0f2259;
            --gold: #d4af37;
            --gold-light: #e6c158;
            --gold-dark: #b8941f;
            --secondary: #6c757d;
            --success: #28a745;
            --info: #17a2b8;
            --warning: #ffc107;
            --danger: #dc3545;
            --light: #f8f9fa;
            --dark: #343a40;
            --gradient-primary: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
        }

        body {
            background-color: #f8f9fc;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            min-height: 100vh;
            padding-bottom: 1rem;
        }

        /* Header styling with Golden West colors */
        .header-bar {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            padding: 1rem;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
            margin-bottom: 1.5rem;
            border-radius: 0 0 0.75rem 0.75rem;
            border-bottom: 3px solid var(--gold);
        }

        .header-title {
            color: white;
            font-size: 1.4rem;
            font-weight: 700;
            margin-bottom: 0;
        }

        /* Card styling consistent with Subjects page */
        .card {
            border: none;
            border-radius: 0.35rem;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.1);
            margin-bottom: 1.5rem;
            transition: all 0.3s ease;
        }

        .card:hover {
            transform: translateY(-2px);
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
        }

        .card-header {
            background-color: #f8f9fc;
            border-bottom: 1px solid #e3e6f0;
            padding: 0.75rem 1.25rem;
            font-weight: 700;
            color: var(--primary);
        }

        /* Domain section styling */
        .domain-section {
            margin-bottom: 1.5rem;
            padding: 1.25rem;
            background: white;
            border-radius: 0.35rem;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.1);
            border-left: 4px solid var(--primary);
        }

        .domain-title {
            font-weight: 700;
            color: var(--primary);
            margin-bottom: 1.25rem;
            padding-bottom: 0.75rem;
            border-bottom: 2px solid var(--gold);
            font-size: 1.1rem;
        }

        /* Table styling consistent with Subjects page */
        .table th {
            border-top: none;
            font-weight: 700;
            color: var(--dark);
            background-color: #f8f9fc;
            text-align: center;
            vertical-align: middle;
            font-size: 0.9rem;
            padding: 0.75rem 0.5rem;
        }

        .table td {
            vertical-align: middle;
            padding: 0.75rem 0.5rem;
        }

        /* Star rating styling */
        .star-rating {
            display: flex;
            justify-content: center;
            gap: 0.25rem;
            flex-wrap: wrap;
        }

        .star {
            font-size: 1.5rem;
            color: #ddd;
            cursor: pointer;
            transition: color 0.2s, transform 0.2s;
            padding: 0.25rem;
        }

        .star:hover {
            color: var(--gold);
            transform: scale(1.1);
        }

        input[type="radio"]:checked ~ label .star {
            color: #ddd;
        }

        input[type="radio"]:checked + label .star,
        input[type="radio"]:hover + label .star,
        .star:hover ~ input[type="radio"]:checked + label .star {
            color: var(--gold);
        }

        input[type="radio"] {
            position: absolute;
            opacity: 0;
        }

        /* Form controls consistent with Subjects page */
        .form-control:focus, .form-select:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 0.2rem rgba(26, 58, 143, 0.25);
        }

        /* Button styling consistent with Subjects page */
        .btn-action {
            padding: 0.75rem 1.5rem;
            font-weight: 600;
            border-radius: 0.35rem;
            font-size: 1rem;
            background: var(--primary);
            border: none;
            color: white;
            transition: all 0.3s ease;
        }

        .btn-action:hover {
            background: var(--primary-dark);
            color: white;
            transform: translateY(-1px);
        }

        .btn-outline-primary {
            border-color: var(--primary);
            color: var(--primary);
        }

        .btn-outline-primary:hover {
            background-color: var(--primary);
            border-color: var(--primary);
            color: white;
        }

        .btn-outline-light {
            border-color: rgba(255, 255, 255, 0.5);
            color: white;
            background-color: rgba(255, 255, 255, 0.1);
        }

        .btn-outline-light:hover {
            background-color: rgba(255, 255, 255, 0.2);
            border-color: var(--gold);
            color: white;
        }

        /* Faculty info card */
        .faculty-info-card {
            background: white;
            border-radius: 0.35rem;
            padding: 1.25rem;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.1);
            margin-bottom: 1.5rem;
            border: 1px solid #e3e6f0;
        }

        /* Info box */
        .info-box {
            background: white;
            border-radius: 0.35rem;
            padding: 1rem;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.1);
            margin-bottom: 1.5rem;
            border-left: 4px solid var(--primary);
        }

        /* Question styling */
        .question-text {
            font-weight: 500;
            color: #333;
            line-height: 1.4;
        }

        /* Golden West specific styling */
        .text-primary {
            color: var(--primary) !important;
        }

        .text-gold {
            color: var(--gold) !important;
        }

        /* Rating guide styling */
        .rating-guide {
            background: white;
            border-radius: 0.35rem;
            padding: 0.75rem;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.1);
            border: 1px solid #e3e6f0;
        }

        .rating-guide-item {
            display: flex;
            align-items: center;
            margin-bottom: 0.25rem;
        }

        .rating-guide-item:last-child {
            margin-bottom: 0;
        }

        /* Terms Modal Styling */
        .terms-modal-content {
            border-radius: 0.75rem;
            border: none;
            box-shadow: 0 1rem 3rem rgba(0, 0, 0, 0.175);
        }

        .terms-modal-header {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            color: white;
            border-bottom: 3px solid var(--gold);
            border-radius: 0.75rem 0.75rem 0 0;
            padding: 1.5rem;
        }

        .terms-modal-body {
            max-height: 60vh;
            overflow-y: auto;
            padding: 2rem;
            background-color: #f8f9fc;
        }

        .terms-section {
            margin-bottom: 2rem;
            padding-bottom: 1.5rem;
            border-bottom: 1px solid #e3e6f0;
        }

        .terms-section:last-child {
            border-bottom: none;
            margin-bottom: 0;
        }

        .terms-section-title {
            color: var(--primary);
            font-weight: 700;
            margin-bottom: 1rem;
            font-size: 1.1rem;
        }

        .terms-list {
            padding-left: 1.5rem;
        }

        .terms-list li {
            margin-bottom: 0.75rem;
            line-height: 1.5;
        }

        .terms-highlight {
            background-color: rgba(212, 175, 55, 0.1);
            border-left: 4px solid var(--gold);
            padding: 1rem;
            border-radius: 0.25rem;
            margin: 1rem 0;
        }

        .terms-checkbox {
            margin-top: 1.5rem;
            padding: 1rem;
            background-color: white;
            border-radius: 0.5rem;
            border: 2px solid #e3e6f0;
            transition: all 0.3s ease;
        }

        .terms-checkbox:has(input:checked) {
            border-color: var(--primary);
            background-color: rgba(26, 58, 143, 0.05);
        }

        .terms-checkbox label {
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            margin-bottom: 0;
        }

        .terms-checkbox input[type="checkbox"] {
            margin-right: 0.75rem;
            transform: scale(1.2);
        }

        /* Validation styles */
        .is-valid {
            border-color: #28a745 !important;
            box-shadow: 0 0 0 0.2rem rgba(40, 167, 69, 0.25) !important;
        }

        .is-invalid {
            border-color: #dc3545 !important;
            box-shadow: 0 0 0 0.2rem rgba(220, 53, 69, 0.25) !important;
        }

        .text-danger {
            color: var(--danger) !important;
        }

        /* Required field indicator */
        .form-label .text-danger {
            font-weight: bold;
        }

        /* Google Translate Widget Styling - Hidden branding */
        #google_translate_element {
            z-index: 9999;
        }

        .goog-te-gadget {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif !important;
            color: transparent !important;
        }

        .goog-te-gadget-simple {
            background-color: rgba(255, 255, 255, 0.1) !important;
            border: 1px solid rgba(255, 255, 255, 0.3) !important;
            border-radius: 0.35rem !important;
            padding: 0.25rem 0.5rem !important;
            font-size: 0.875rem !important;
            color: white !important;
            cursor: pointer !important;
            transition: all 0.3s ease !important;
            display: flex !important;
            align-items: center !important;
        }

        .goog-te-gadget-simple:hover {
            background-color: rgba(255, 255, 255, 0.2) !important;
            border-color: var(--gold) !important;
        }

        .goog-te-menu-value span {
            color: white !important;
        }

        .goog-te-menu-value i {
            display: none !important;
        }

        .goog-te-gadget-simple .goog-te-menu-value {
            color: white !important;
            display: flex !important;
            align-items: center !important;
        }

        /* Hide Google Translate Branding */
        .goog-logo-link,
        .goog-te-gadget span,
        .goog-te-banner-frame,
        .goog-te-menu-value img,
        .goog-te-gadget .goog-te-combo {
            display: none !important;
        }

        .goog-te-gadget .goog-te-combo {
            margin: 0 !important;
            color: var(--dark) !important;
        }

        /* Custom language selector styling */
        .custom-language-selector {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.3);
            border-radius: 0.35rem;
            padding: 0.25rem 0.5rem;
            color: white;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 0.875rem;
        }

        .custom-language-selector:hover {
            background: rgba(255, 255, 255, 0.2);
            border-color: var(--gold);
        }

        .custom-language-selector i {
            font-size: 1rem;
        }

        /* Translate dropdown styling */
        .goog-te-menu2 {
            background: white !important;
            border: none !important;
            border-radius: 0.35rem !important;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15) !important;
        }

        .goog-te-menu2-item div,
        .goog-te-menu2-item-selected div {
            padding: 0.5rem 1rem !important;
            color: var(--dark) !important;
        }

        .goog-te-menu2-item:hover {
            background-color: #f8f9fa !important;
        }

        .goog-te-menu2-item-selected {
            background-color: var(--primary) !important;
        }

        .goog-te-menu2-item-selected div {
            color: white !important;
        }

        /* Enhanced Mobile Responsiveness */
        @media (max-width: 768px) {
            body {
                padding-bottom: 0.5rem;
            }
            
            .header-bar {
                padding: 0.875rem;
                margin-bottom: 1.25rem;
            }
            
            .header-title {
                font-size: 1.25rem;
            }
            
            .container {
                padding-left: 0.75rem;
                padding-right: 0.75rem;
            }
            
            .card-body {
                padding: 1rem;
            }
            
            .domain-section {
                padding: 1rem;
                margin-bottom: 1.25rem;
            }
            
            .domain-title {
                font-size: 1rem;
                margin-bottom: 1rem;
            }
            
            .table-responsive {
                border-radius: 0.35rem;
                margin-bottom: 1rem;
            }
            
            .star {
                font-size: 1.3rem;
                padding: 0.2rem;
            }
            
            .row.mb-3 {
                margin-bottom: 1rem !important;
            }
            
            .btn-action {
                width: 100%;
                margin-bottom: 0.5rem;
            }
            
            .faculty-info-card {
                padding: 1rem;
            }
            
            .info-box {
                padding: 0.875rem;
            }
            
            .terms-modal-body {
                padding: 1.5rem;
                max-height: 50vh;
            }
            
            .terms-section {
                margin-bottom: 1.5rem;
                padding-bottom: 1rem;
            }
            
            /* Improved mobile header layout */
            .header-bar .d-flex {
                flex-direction: column;
                align-items: flex-start !important;
            }
            
            .header-bar .d-flex > div {
                margin-bottom: 0.5rem;
            }
            
            .header-bar .d-flex > div:last-child {
                margin-bottom: 0;
                flex-direction: row;
                flex-wrap: wrap;
                gap: 0.5rem;
            }
            
            /* Mobile-optimized table layout */
            .table thead {
                display: none;
            }
            
            .table tbody tr {
                display: block;
                margin-bottom: 1rem;
                border: 1px solid #dee2e6;
                border-radius: 0.35rem;
                background: white;
                box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.1);
            }
            
            .table tbody td {
                display: block;
                text-align: left;
                border: none;
                padding: 0.75rem;
            }
            
            .table tbody td:first-child {
                background-color: #f8f9fc;
                font-weight: 600;
                border-bottom: 1px solid #e3e6f0;
                border-radius: 0.35rem 0.35rem 0 0;
            }
            
            .table tbody td:last-child {
                text-align: center;
            }
            
            /* Mobile rating guide */
            .rating-guide {
                padding: 0.5rem;
            }
            
            .rating-guide-item {
                font-size: 0.85rem;
            }
            
            /* Mobile star ratings */
            .star-rating {
                gap: 0.15rem;
            }
            
            .star {
                font-size: 1.1rem;
                padding: 0.15rem;
            }
        }

        @media (max-width: 576px) {
            .header-bar {
                padding: 0.75rem;
                margin-bottom: 1rem;
            }
            
            .header-title {
                font-size: 1.1rem;
            }
            
            .container {
                padding-left: 0.5rem;
                padding-right: 0.5rem;
            }
            
            .card-body {
                padding: 0.75rem;
            }
            
            .domain-section {
                padding: 0.75rem;
                margin-bottom: 1rem;
            }
            
            .table th, .table td {
                padding: 0.5rem 0.25rem;
                font-size: 0.85rem;
            }
            
            .star {
                font-size: 1.1rem;
                padding: 0.15rem;
            }
            
            .form-label {
                font-size: 0.9rem;
                margin-bottom: 0.25rem;
            }
            
            .form-control, .form-select {
                font-size: 0.9rem;
                padding: 0.5rem 0.75rem;
            }
            
            .btn-action {
                padding: 0.6rem 1rem;
                font-size: 0.9rem;
            }
            
            .faculty-info-card {
                padding: 0.875rem;
            }
            
            .terms-modal-body {
                padding: 1rem;
                max-height: 45vh;
            }
            
            .terms-modal-header {
                padding: 1.25rem;
            }
            
            /* Improved mobile buttons */
            .header-bar .btn {
                font-size: 0.8rem;
                padding: 0.4rem 0.75rem;
            }
            
            /* Mobile text adjustments */
            .question-text {
                font-size: 0.9rem;
            }
        }

        @media (max-width: 400px) {
            .header-title {
                font-size: 1rem;
            }
            
            .star {
                font-size: 1rem;
            }
            
            .domain-title {
                font-size: 0.95rem;
            }
            
            .table tbody td {
                padding: 0.5rem;
                font-size: 0.8rem;
            }
            
            .btn-action {
                padding: 0.5rem 0.75rem;
                font-size: 0.85rem;
            }
            
            .faculty-info-card {
                padding: 0.75rem;
            }
            
            /* Ultra-mobile adjustments */
            .header-bar .d-flex > div:last-child {
                flex-direction: column;
                width: 100%;
            }
            
            .header-bar .btn {
                width: 100%;
                margin-bottom: 0.25rem;
            }
            
            .header-bar .btn:last-child {
                margin-bottom: 0;
            }
        }

        /* Animation for alerts */
        .alert-slide {
            animation: slideIn 0.5s forwards;
        }

        @keyframes slideIn {
            from {
                transform: translateY(-20px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }

        /* Touch-friendly improvements */
        .btn, .star, .form-control, .form-select {
            -webkit-tap-highlight-color: transparent;
            touch-action: manipulation;
        }

        /* Prevent horizontal scrolling */
        html, body {
            max-width: 100%;
            overflow-x: hidden;
        }

        /* Enhanced focus states for accessibility */
        .star:focus {
            outline: 2px solid var(--primary);
            outline-offset: 2px;
            border-radius: 50%;
        }

        /* Loading state for submit button */
        .btn-loading {
            position: relative;
            color: transparent;
        }

        .btn-loading::after {
            content: '';
            position: absolute;
            width: 1rem;
            height: 1rem;
            top: 50%;
            left: 50%;
            margin-left: -0.5rem;
            margin-top: -0.5rem;
            border: 2px solid transparent;
            border-top-color: currentColor;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* Animation for cards */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .animate-card {
            animation: fadeInUp 0.6s ease-out;
        }

     
/* Updated star rating styles for consistent column width */
.table th:nth-child(2),
.table td:nth-child(2) {
    width: 200px;
    min-width: 200px;
    max-width: 200px;
}

.star-rating {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 0.25rem;
    flex-wrap: nowrap;
    width: 100%;
}

.star {
    font-size: 1.5rem;
    color: #ddd;
    cursor: pointer;
    transition: color 0.2s, transform 0.2s;
    padding: 0.15rem;
    flex-shrink: 0;
}

.star:hover {
    color: var(--gold);
    transform: scale(1.1);
}

input[type="radio"]:checked ~ label .star {
    color: #ddd;
}

input[type="radio"]:checked + label .star,
input[type="radio"]:hover + label .star,
.star:hover ~ input[type="radio"]:checked + label .star {
    color: var(--gold);
}

input[type="radio"] {
    position: absolute;
    opacity: 0;
}

/* Ensure consistent table layout */
.table {
    table-layout: fixed;
}

.table th, .table td {
    vertical-align: middle;
}

/* Mobile adjustments for star ratings */
@media (max-width: 768px) {
    .table th:nth-child(2),
    .table td:nth-child(2) {
        width: 100%;
        min-width: 100%;
        max-width: 100%;
    }
    
    .star {
        font-size: 1.3rem;
        padding: 0.1rem;
    }
}

@media (max-width: 576px) {
    .star {
        font-size: 1.1rem;
    }
    
    .star-rating {
        gap: 0.15rem;
    }
}

    </style>
    <!-- Google Translate Script -->
    <script type="text/javascript">
        function googleTranslateElementInit() {
            new google.translate.TranslateElement({
                pageLanguage: 'en',
                includedLanguages: 'en,tl,fil',
                layout: google.translate.TranslateElement.InlineLayout.SIMPLE,
                autoDisplay: false
            }, 'google_translate_element');

            // Hide Google branding after initialization
            setTimeout(function () {
                var iframes = document.getElementsByTagName('iframe');
                for (var i = 0; i < iframes.length; i++) {
                    if (iframes[i].title.includes('Translate')) {
                        iframes[i].style.display = 'none';
                    }
                }

                // Hide Google logo and branding
                var googleBranding = document.querySelector('.goog-logo-link');
                if (googleBranding) googleBranding.style.display = 'none';

                var googleText = document.querySelector('.goog-te-gadget span');
                if (googleText) googleText.style.display = 'none';

                // Customize the translate button
                var translateButton = document.querySelector('.goog-te-menu-value');
                if (translateButton) {
                    translateButton.innerHTML = '<i class="bi bi-translate me-1"></i> Language';
                }
            }, 500);
        }

    </script>
    <script type="text/javascript" src="//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit"></script>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Header -->
        <div class="header-bar">
            <div class="d-flex justify-content-between align-items-center">
                <div class="d-flex align-items-center">
                    <i class="bi bi-clipboard-check me-2 fs-4" style="color: white;"></i>
                    <h2 class="header-title">Evaluate Faculty</h2>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <!-- Google Translate Element -->
                    <div id="google_translate_element" class="me-2"></div>
                    <a href="StudentDashboard.aspx" class="btn btn-outline-light btn-sm">
                        <i class="bi bi-arrow-left me-1"></i>Back to Dashboard
                    </a>
                </div>
            </div>
        </div>

        <div class="container">
            <!-- Alert Message -->
            <asp:Label ID="lblMessage" runat="server" CssClass="alert d-none alert-slide"></asp:Label>

          <!-- Terms and Conditions Modal -->
<div class="modal fade" id="termsModal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="termsModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content terms-modal-content">
            <div class="modal-header terms-modal-header">
                <h3 class="modal-title" id="termsModalLabel">
                    <i class="bi bi-shield-check me-2"></i>Faculty Evaluation Policy & Terms
                </h3>
            </div>
            <div class="modal-body terms-modal-body">
                <div class="terms-section">
                    <h4 class="terms-section-title">Evaluation Policy</h4>
                    <p>Before proceeding with the faculty evaluation, please read and understand the following policies:</p>
                    
                    <div class="terms-highlight">
                        <i class="bi bi-exclamation-triangle-fill text-warning me-2"></i>
                        <strong>Important:</strong> Your evaluation contributes to the continuous improvement of teaching quality at our institution.
                    </div>
                    
                    <ul class="terms-list">
                        <li>Evaluations are <strong>anonymous and confidential</strong>. Your identity will not be revealed to the faculty member.</li>
                        <li>Provide <strong>honest and constructive feedback</strong> based on your actual learning experience.</li>
                        <li>Evaluations should be completed <strong>within the designated evaluation period</strong>.</li>
                        <li>Once submitted, evaluations <strong>cannot be modified or withdrawn</strong>.</li>
                        <li>Your feedback will be used for <strong>faculty development and improvement purposes</strong>.</li>
                    </ul>
                </div>
                
                <!-- NEW SECTION: Strict Confidentiality Policy -->
                <div class="terms-section">
                    <h4 class="terms-section-title">Strict Confidentiality Policy</h4>
                    
                    <div class="terms-highlight" style="border-left-color: #dc3545; background-color: rgba(220, 53, 69, 0.05);">
                        <i class="bi bi-ban-fill text-danger me-2"></i>
                        <strong>Strictly Prohibited:</strong> Taking screenshots, photos, sharing, or showing one's own evaluation submission results to others is strictly prohibited.
                    </div>
                    
                    <ul class="terms-list">
                        <li><strong>Confidentiality Breach:</strong> Any form of reproduction, distribution, or disclosure of evaluation results constitutes a serious violation of institutional policy.</li>
                        <li><strong>Investigation Process:</strong> Students found violating this policy will have their academic records temporarily held pending investigation.</li>
                        <li><strong>Disciplinary Action:</strong> If proven to have violated this confidentiality agreement, the student may be subject to disciplinary action, including possible dismissal from the institution.</li>
                        <li><strong>Legal Basis:</strong> This policy is enforced under <strong>Republic Act No. 10173</strong> (Data Privacy Act of 2012).</li>
                    </ul>
                    
                    <div class="mt-3 p-3 border rounded" style="background-color: #fff3cd; border-color: #ffeaa7 !important;">
                        <h6 class="fw-bold text-dark mb-2">
                            <i class="bi bi-shield-exclamation me-2"></i>Legal References:
                        </h6>
                        <ul class="mb-0">
                            <li><strong>Republic Act No. 10173</strong> - Data Privacy Act of 2012</li>
                         
                        </ul>
                    </div>
                </div>
                
                <div class="terms-section">
                    <h4 class="terms-section-title">Evaluation Guidelines</h4>
                    <ul class="terms-list">
                        <li>Rate each criterion based on your experience throughout the semester.</li>
                        <li>Use the 5-point scale where 1 = Strongly Disagree and 5 = Strongly Agree.</li>
                        <li><strong>All comment fields are required</strong> - provide specific, actionable feedback.</li>
                        <li>Focus on teaching methods, communication, and learning environment.</li>
                        <li>Avoid personal comments unrelated to teaching effectiveness.</li>
                        <li>Each comment must be at least 10 characters long.</li>
                    </ul>
                </div>
                
                <div class="terms-section">
                    <h4 class="terms-section-title">Data Usage & Privacy</h4>
                    <ul class="terms-list">
                        <li>Evaluation data is aggregated for reporting purposes.</li>
                        <li>Individual comments may be shared with faculty members.</li>
                        <li>Results are used by department chairs for faculty review.</li>
                        <li>Data is stored securely and accessed only by authorized personnel.</li>
                        <li>Your participation is voluntary but highly encouraged.</li>
                    </ul>
                </div>
                
                <div class="terms-checkbox">
                    <label>
                        <asp:CheckBox ID="chkAgreeTerms" runat="server" />
                        <span class="ms-2">
                            I have read, understood, and agree to abide by the Faculty Evaluation Policy and Terms, including the <strong>Strict Confidentiality Policy</strong>. 
                            I confirm that my evaluation will be honest, constructive, and based on my actual learning experience. 
                            I understand that <strong>sharing, reproducing, or disclosing my evaluation results is strictly prohibited</strong> and may result in disciplinary action including dismissal.
                        </span>
                    </label>
                </div>
            </div>
            <div class="modal-footer">
                <asp:Button ID="btnCancel" runat="server" Text="Cancel Evaluation" 
                          CssClass="btn btn-outline-secondary" OnClick="btnCancel_Click" />
                <asp:Button ID="btnAcceptTerms" runat="server" Text="Accept & Continue" 
                          CssClass="btn btn-action" OnClick="btnAcceptTerms_Click" Enabled="false" />
            </div>
        </div>
    </div>
</div>

            <asp:Panel ID="pnlEvaluate" runat="server" Visible="false">
                <div class="card animate-card">
                    <div class="card-header d-flex align-items-center">
                        <i class="bi bi-person-check me-2"></i>
                        Faculty Evaluation
                    </div>
                    <div class="card-body">
                        <!-- Faculty Load Selection -->
                        <div class="row mb-3">
                            <div class="col-12">
                                <label for="ddlFacultyLoad" class="form-label fw-bold">Select Subject/Instructor:</label>
                                <asp:DropDownList ID="ddlFacultyLoad" runat="server" CssClass="form-select" AutoPostBack="true"></asp:DropDownList>
                            </div>
                        </div>

                        <!-- Info Box -->
                        <div class="info-box">
                            <i class="bi bi-info-circle text-primary me-2"></i>
                            <small>Select a faculty member to evaluate their teaching performance</small>
                        </div>

                        <!-- Faculty Info Card (if available) -->
                        <asp:Panel ID="pnlFacultyInfo" runat="server" Visible="false" CssClass="faculty-info-card">
                            <div class="row">
                                <div class="col-md-6 mb-3 mb-md-0">
                                    <h6 class="fw-bold mb-3 text-primary">Faculty Information</h6>
                                    <div class="d-flex align-items-center mb-2">
                                        <i class="bi bi-person me-2 text-primary"></i>
                                        <div>
                                            <small class="text-muted d-block">Instructor</small>
                                            <div class="fw-semibold"><asp:Label ID="lblFacultyName" runat="server" /></div>
                                        </div>
                                    </div>
                                    <div class="d-flex align-items-center mb-2">
                                        <i class="bi bi-journal-bookmark me-2 text-primary"></i>
                                        <div>
                                            <small class="text-muted d-block">Subject</small>
                                            <div class="fw-semibold"><asp:Label ID="lblSubject" runat="server" /></div>
                                        </div>
                                    </div>
                                    <div class="d-flex align-items-center">
                                        <i class="bi bi-building-gear me-2 text-primary"></i>
                                        <div>
                                            <small class="text-muted d-block">Department</small>
                                            <div class="fw-semibold"><asp:Label ID="lblDepartment" runat="server" /></div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <h6 class="fw-bold mb-3 text-primary">Rating Guide</h6>
                                    <div class="rating-guide">
                                        <div class="rating-guide-item">
                                            <i class="bi bi-star-fill text-warning me-2"></i>
                                            <small>1 = Not applicable / Not enough opportunity to observe</small>
                                        </div>
                                        <div class="rating-guide-item">
                                            <i class="bi bi-star-fill text-warning me-2"></i>
                                            <small>2 = Never</small>
                                        </div>
                                        <div class="rating-guide-item">
                                            <i class="bi bi-star-fill text-warning me-2"></i>
                                            <small>3 = Sometimes</small>
                                        </div>
                                        <div class="rating-guide-item">
                                            <i class="bi bi-star-fill text-warning me-2"></i>
                                            <small>4 =Often</small>
                                        </div>
                                        <div class="rating-guide-item">
                                            <i class="bi bi-star-fill text-warning me-2"></i>
                                            <small>5 = Always</small>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </asp:Panel>

                   <asp:Repeater ID="rptDomains" runat="server" OnItemDataBound="rptDomains_ItemDataBound">
    <ItemTemplate>
        <div class="domain-section animate-card">
            <asp:HiddenField ID="hfDomainID" runat="server" Value='<%# Eval("DomainID") %>' />
            <div class="domain-title d-flex align-items-center">
                <i class="bi bi-collection me-2"></i><%# Eval("DomainName") %>
            </div>
            <div class="table-responsive">
                <asp:Repeater ID="rptDomainQuestions" runat="server">
                    <HeaderTemplate>
                        <table class="table table-bordered mb-0">
                            <thead class="table-light d-none d-sm-table-header-group">
                                <tr>
                                    <th style="width:calc(100% - 200px)">Question</th>
                                    <th class="text-center" style="width:200px">Rating</th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td>
                                <asp:HiddenField ID="hfQuestionID" runat="server" Value='<%# Eval("QuestionID") %>' />
                                <i class="bi bi-chat-square-text me-2 text-primary"></i>
                                <span class="question-text"><%# Eval("QuestionText") %></span>
                            </td>
                            <td class="text-center">
                                <div class="star-rating">
                                    <asp:RadioButtonList ID="rblRating" runat="server" RepeatDirection="Horizontal" 
                                        CssClass="star-rating" RepeatLayout="Flow">
                                        <asp:ListItem Value="1"><i class="bi bi-star-fill star" title="Not applicable / Not enough opportunity to observe"></i></asp:ListItem>
                                        <asp:ListItem Value="2"><i class="bi bi-star-fill star" title="Never"></i></asp:ListItem>
                                        <asp:ListItem Value="3"><i class="bi bi-star-fill star" title="Sometimes"></i></asp:ListItem>
                                        <asp:ListItem Value="4"><i class="bi bi-star-fill star" title="Often"></i></asp:ListItem>
                                        <asp:ListItem Value="5"><i class="bi bi-star-fill star" title="Always"></i></asp:ListItem>
                                    </asp:RadioButtonList>
                                </div>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                            </tbody>
                        </table>
                    </FooterTemplate>
                </asp:Repeater>
            </div>
        </div>
    </ItemTemplate>
</asp:Repeater>

                      <!-- Strength Comment - MANDATORY -->
<div class="mb-4">
    <label for="txtStrength" class="form-label fw-bold">
        <i class="bi bi-award me-1"></i>Strengths <span class="text-danger">*</span>:
    </label>
    <asp:TextBox ID="txtStrength" runat="server" CssClass="form-control"
                TextMode="MultiLine" Rows="3" 
                placeholder="Please describe what you believe are the instructor's strengths..."></asp:TextBox>
    <small class="text-muted">This field is required</small>
</div>

<!-- Weakness Comment - MANDATORY -->
<div class="mb-4">
    <label for="txtWeakness" class="form-label fw-bold">
        <i class="bi bi-lightbulb me-1"></i>Areas for Improvement <span class="text-danger">*</span>:
    </label>
    <asp:TextBox ID="txtWeakness" runat="server" CssClass="form-control"
                TextMode="MultiLine" Rows="3" 
                placeholder="Please provide constructive feedback on areas where the instructor could improve..."></asp:TextBox>
    <small class="text-muted">This field is required</small>
</div>

<!-- Message - MANDATORY -->
<div class="mb-4">
    <label for="txtMessage" class="form-label fw-bold">
        <i class="bi bi-chat-left-text me-1"></i>Additional Message <span class="text-danger">*</span>:
    </label>
    <asp:TextBox ID="txtMessage" runat="server" CssClass="form-control"
                TextMode="MultiLine" Rows="3" 
                placeholder="Please provide any additional feedback or comments about your learning experience..."></asp:TextBox>
    <small class="text-muted">This field is required</small>
</div>

                        <!-- Submit -->
                        <div class="d-grid gap-2">
                            <asp:Button ID="btnSubmit" runat="server" Text="Submit Evaluation"
                                        CssClass="btn btn-action" OnClick="btnSubmit_Click" />
                        </div>
                    </div>
                </div>
            </asp:Panel>

            <!-- Empty State -->
            <asp:Panel ID="pnlNoEvaluation" runat="server" Visible="false" CssClass="text-center py-4">
                <i class="bi bi-clipboard-x display-4 text-muted"></i>
                <h4 class="text-muted mt-3">No Evaluation Available</h4>
                <p class="text-muted mb-3">There are no faculty members available for evaluation at this time.</p>
                <a href="StudentDashboard.aspx" class="btn btn-primary">
                    <i class="bi bi-arrow-left me-1"></i>Back to Dashboard
                </a>
            </asp:Panel>
        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            // Check if terms need to be shown
            var termsAccepted = '<%= Session("EvaluationTermsAccepted") %>' === 'True';

            if (!termsAccepted) {
                var termsModal = new bootstrap.Modal(document.getElementById('termsModal'));
                termsModal.show();
            }

            // Enable/disable accept button based on checkbox
            var agreeCheckbox = document.getElementById('<%= chkAgreeTerms.ClientID %>');
            var acceptButton = document.getElementById('<%= btnAcceptTerms.ClientID %>');
            
            if (agreeCheckbox && acceptButton) {
                agreeCheckbox.addEventListener('change', function() {
                    acceptButton.disabled = !this.checked;
                });
            }

            const radioLists = document.querySelectorAll('.star-rating');

            radioLists.forEach(list => {
                const radios = list.querySelectorAll('input[type="radio"]');
                const labels = list.querySelectorAll('label .star');

                function updateStars(value) {
                    labels.forEach((star, index) => {
                        if (index < value) {
                            star.style.color = '#ffc107'; // highlight
                        } else {
                            star.style.color = '#ddd'; // reset
                        }
                    });
                }

                // Handle click
                radios.forEach((radio, idx) => {
                    radio.addEventListener('change', () => {
                        updateStars(parseInt(radio.value));
                    // Add visual feedback for selection
                        const parentRow = radio.closest('tr');
                        if (parentRow) {
                            parentRow.style.backgroundColor = '#f8f9fc';
                            setTimeout(() => {
                                parentRow.style.backgroundColor = '';
                            }, 300);
                        }
                    });
                    
                    // Add touch event for mobile
                    const label = radio.nextElementSibling;
                    if (label) {
                        label.addEventListener('touchstart', (e) => {
                            e.preventDefault();
                            radio.checked = true;
                            radio.dispatchEvent(new Event('change'));
                        });
                    }
                });

                // Initialize (for already selected answers)
                const checked = list.querySelector('input[type="radio"]:checked');
                if (checked) {
                    updateStars(parseInt(checked.value));
                }
            });

            // Add loading state to submit button
            const submitBtn = document.getElementById('<%= btnSubmit.ClientID %>');
            if (submitBtn) {
                submitBtn.addEventListener('click', function () {
                    this.classList.add('btn-loading');
                    setTimeout(() => {
                        this.classList.remove('btn-loading');
                    }, 3000);
                });
            }

            // Animation for cards
            const cards = document.querySelectorAll('.animate-card');
            cards.forEach((card, index) => {
                card.style.animationDelay = (index * 0.1) + 's';
            });

            // Hide Google Translate branding
            hideGoogleBranding();
            
            // Re-hide branding periodically as Google Translate might re-add it
            setInterval(hideGoogleBranding, 1000);
        });

        function hideGoogleBranding() {
            // Hide Google Translate logo and branding
            var googleBranding = document.querySelector('.goog-logo-link');
            if (googleBranding) googleBranding.style.display = 'none';
            
            var googleText = document.querySelector('.goog-te-gadget span');
            if (googleText) googleText.style.display = 'none';
            
            var googleBanner = document.querySelector('.goog-te-banner-frame');
            if (googleBanner) googleBanner.style.display = 'none';
            
            var googleImages = document.querySelectorAll('.goog-te-menu-value img');
            googleImages.forEach(img => img.style.display = 'none');
            
            // Customize the translate button
            var translateButton = document.querySelector('.goog-te-menu-value');
            if (translateButton && !translateButton.innerHTML.includes('bi-translate')) {
                translateButton.innerHTML = '<i class="bi bi-translate me-1"></i> Language';
            }
        }

        // Function to hide modal (called from server-side)
        function hideTermsModal() {
            var modal = bootstrap.Modal.getInstance(document.getElementById('termsModal'));
            if (modal) {
                modal.hide();
            }
            // Alternative method
            var modalElement = document.getElementById('termsModal');
            var modalInstance = bootstrap.Modal.getInstance(modalElement);
            if (modalInstance) {
                modalInstance.hide();
            }
            // Fallback: remove backdrop and hide manually
            document.body.classList.remove('modal-open');
            var backdrops = document.querySelectorAll('.modal-backdrop');
            backdrops.forEach(function (backdrop) {
                backdrop.remove();
            });
            modalElement.style.display = 'none';
        }
        
        // Real-time validation for comment fields
        const commentFields = ['<%= txtStrength.ClientID %>', '<%= txtWeakness.ClientID %>', '<%= txtMessage.ClientID %>'];
        commentFields.forEach(fieldId => {
            const field = document.getElementById(fieldId);
            if (field) {
                field.addEventListener('input', function () {
                    const isValid = this.value.trim().length >= 10;
                    if (isValid) {
                        this.classList.remove('is-invalid');
                        this.classList.add('is-valid');
                    } else {
                        this.classList.remove('is-valid');
                        this.classList.add('is-invalid');
                    }
                });

                // Initial validation
                field.dispatchEvent(new Event('input'));
            }
        });
    </script>
</body>
</html>                     
