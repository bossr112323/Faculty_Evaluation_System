<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="MyEvaluations.aspx.vb" Inherits="Faculty_Evaluation_System.MyEvaluations" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Evaluations - Faculty Evaluation System</title>
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
            padding-bottom: 0.25rem;
            font-size: 0.85rem;
        }

        /* Header styling with Golden West colors - UNCHANGED */
        .header-bar {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            padding: 1rem;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
            margin-bottom: 0.75rem;
            border-radius: 0 0 0.75rem 0.75rem;
            border-bottom: 3px solid var(--gold);
        }
        
        .header-title {
            color: white;
            font-size: 1.4rem;
            font-weight: 700;
            margin-bottom: 0;
        }

        /* EXTREMELY COMPACT Card styling */
        .card {
            border: none;
            border-radius: 0.25rem;
            box-shadow: 0 0.05rem 0.3rem 0 rgba(58, 59, 69, 0.08);
            margin-bottom: 0.5rem;
            border-left: 3px solid var(--primary);
        }

        /* EXTREMELY COMPACT Submission header */
        .submission-header {
            background-color: #f8f9fc;
            padding: 0.5rem 0.75rem;
            border-bottom: 1px solid #e3e6f0;
        }

        /* EXTREMELY COMPACT Table styling */
        .table {
            font-size: 0.8rem;
            margin-bottom: 0;
        }

        .table th {
            border-top: none;
            font-weight: 600;
            color: var(--dark);
            background-color: #f8f9fc;
            padding: 0.25rem 0.5rem;
        }

        .table td {
            padding: 0.25rem 0.5rem;
            vertical-align: middle;
        }

        .score-cell {
            font-weight: 600;
        }

        .score-high { color: var(--success); }
        .score-good { color: var(--info); }
        .score-medium { color: var(--warning); }
        .score-low { color: var(--warning); }
        .score-poor { color: var(--danger); }

        /* EXTREMELY COMPACT Star rating */
        .star-rating-readonly {
            display: flex;
            justify-content: center;
            gap: 0.1rem;
            flex-wrap: nowrap;
        }

        .star-readonly {
            font-size: 0.9rem;
            flex-shrink: 0;
        }

        .star-filled {
            color: var(--gold);
        }

        .star-empty {
            color: #ddd;
        }

        /* EXTREMELY COMPACT Rating breakdown */
        .rating-breakdown {
            border-left: 1px solid #e3e6f0;
            padding-left: 0.75rem;
        }

        .total-score-box {
            text-align: center;
            padding: 0.5rem;
            background: white;
            border-radius: 0.2rem;
            margin-bottom: 0.5rem;
            box-shadow: 0 0.05rem 0.2rem 0 rgba(58, 59, 69, 0.05);
            border: 1px solid #e3e6f0;
        }

        .score-badge {
            font-size: 0.7rem;
            padding: 0.2rem 0.5rem;
        }

        /* EXTREMELY COMPACT Comment boxes */
        .comment-box {
            background: white;
            padding: 0.4rem 0.5rem;
            border-radius: 0.15rem;
            margin-bottom: 0.4rem;
            border-left: 2px solid #e3e6f0;
            font-size: 0.75rem;
        }

        .strength-box {
            border-left-color: var(--success);
        }

        .weakness-box {
            border-left-color: var(--warning);
        }

        .message-box {
            border-left-color: var(--info);
        }

        /* Button styling */
        .btn-outline-light {
            border-color: rgba(255, 255, 255, 0.5);
            color: white;
            background-color: rgba(255, 255, 255, 0.1);
            font-size: 0.8rem;
            padding: 0.25rem 0.5rem;
        }
        
        .btn-primary {
            background-color: var(--primary);
            border-color: var(--primary);
            font-size: 0.75rem;
            padding: 0.2rem 0.5rem;
        }

        .btn-outline-primary {
            border-color: var(--primary);
            color: var(--primary);
            font-size: 0.75rem;
            padding: 0.2rem 0.5rem;
        }

        /* EXTREMELY COMPACT Score display */
        .actual-score {
            font-size: 0.85rem;
            font-weight: 600;
        }

        .score-out-of {
            font-size: 0.65rem;
            color: var(--secondary);
        }

        /* EXTREMELY COMPACT Empty state */
        .empty-state {
            text-align: center;
            padding: 1rem 0.5rem;
            color: var(--secondary);
        }

        /* EXTREMELY COMPACT Card body */
        .card-body {
            padding: 0.5rem;
        }

        /* EXTREMELY COMPACT Toggle button */
        .toggle-btn {
            font-size: 0.75rem;
            padding: 0.3rem 0.5rem;
            margin-top: 0.5rem;
        }

        /* EXTREMELY COMPACT Domain section for detailed questions */
        .domain-section {
            margin-bottom: 0.5rem;
            padding: 0.5rem;
            background: white;
            border-radius: 0.15rem;
            border-left: 2px solid var(--primary);
        }

        .domain-title {
            font-weight: 600;
            color: var(--primary);
            margin-bottom: 0.3rem;
            padding-bottom: 0.2rem;
            border-bottom: 1px solid var(--gold);
            font-size: 0.8rem;
        }

        /* Mobile-first responsive design */
        @media (max-width: 768px) {
            body {
                font-size: 0.8rem;
            }
            
            .header-bar {
                padding: 0.75rem;
                margin-bottom: 0.5rem;
            }
            
            .header-title {
                font-size: 1.2rem;
            }
            
            .container {
                padding-left: 0.5rem;
                padding-right: 0.5rem;
            }
            
            .submission-header {
                padding: 0.4rem 0.5rem;
            }
            
            .card-body {
                padding: 0.4rem;
            }
            
            .table th, .table td {
                padding: 0.2rem 0.3rem;
                font-size: 0.75rem;
            }
            
            .total-score-box {
                padding: 0.4rem;
                margin-bottom: 0.3rem;
            }
            
            .total-score-box h1 {
                font-size: 1.2rem;
            }
            
            .score-badge {
                font-size: 0.65rem;
            }
            
            .comment-box {
                padding: 0.3rem 0.4rem;
                margin-bottom: 0.3rem;
            }

            .star-readonly {
                font-size: 0.8rem;
            }

            .rating-breakdown {
                border-left: none;
                border-top: 1px solid #e3e6f0;
                padding-left: 0;
                padding-top: 0.5rem;
                margin-top: 0.5rem;
            }
        }

        @media (max-width: 576px) {
            body {
                padding-bottom: 0.1rem;
                font-size: 0.75rem;
            }
            
            .header-bar {
                padding: 0.6rem;
                margin-bottom: 0.4rem;
            }
            
            .header-title {
                font-size: 1.1rem;
            }
            
            .submission-header {
                padding: 0.3rem 0.4rem;
            }
            
            .card-body {
                padding: 0.3rem;
            }
            
            .table th, .table td {
                padding: 0.15rem 0.2rem;
                font-size: 0.7rem;
            }
            
            .total-score-box {
                padding: 0.3rem;
            }
            
            .total-score-box h1 {
                font-size: 1rem;
            }
            
            .score-badge {
                font-size: 0.6rem;
                padding: 0.15rem 0.3rem;
            }
            
            .comment-box {
                padding: 0.25rem 0.3rem;
                font-size: 0.7rem;
            }
            
            .empty-state {
                padding: 0.75rem 0.4rem;
            }
            
            .empty-state .display-1 {
                font-size: 2rem;
            }
            
            .empty-state h4 {
                font-size: 0.9rem;
            }

            .star-readonly {
                font-size: 0.7rem;
            }
        }

        /* Ultra-compact utility classes */
        .compact-text {
            font-size: 0.8rem;
        }

        .compact-text-sm {
            font-size: 0.75rem;
        }

        .compact-padding {
            padding: 0.3rem;
        }

        .no-margin {
            margin: 0;
        }

        /* Compact badge styles */
        .badge-sm {
            font-size: 0.65rem;
            padding: 0.15rem 0.3rem;
        }

        /* Compact table */
        .table-compact th,
        .table-compact td {
            padding: 0.2rem 0.3rem;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Header - UNCHANGED -->
        <div class="header-bar">
            <div class="d-flex justify-content-between align-items-center">
                <div class="d-flex align-items-center">
                    <i class="bi bi-list-check me-2 fs-4" style="color: white;"></i>
                    <h2 class="header-title">My Evaluations</h2>
                </div>
                <div>
                    <a href="StudentDashboard.aspx" class="btn btn-outline-light btn-sm">
                        <i class="bi bi-arrow-left me-1"></i>Back to Dashboard
                    </a>
                </div>
            </div>
        </div>

        <div class="container">
            <!-- Alert Message -->
            <asp:Label ID="lblMessage" runat="server" CssClass="alert d-none mb-1 compact-text-sm"></asp:Label>
            
            <!-- ULTRA COMPACT Evaluations List -->
            <asp:Repeater ID="rptSubmissions" runat="server" OnItemDataBound="rptSubmissions_ItemDataBound">
                <ItemTemplate>
                    <div class="card">
                        <!-- ULTRA COMPACT Submission Header -->
                        <div class="submission-header">
                            <div class="d-flex justify-content-between align-items-start flex-column flex-sm-row no-margin">
                                <div class="mb-0">
                                    <h6 class="mb-1 fw-bold compact-text no-margin">
                                        <i class="bi bi-person-check me-1 text-primary"></i><%# Eval("FacultyName") %>
                                    </h6>
                                    <div class="d-flex flex-wrap gap-1 gap-sm-2 compact-text-sm">
                                        <span class="text-muted"><%# Eval("SubjectName") %></span>
                                        <span class="text-muted">•</span>
                                        <span class="text-muted"><%# Eval("Term") %></span>
                                        <span class="text-muted">•</span>
                                        <span class="text-muted"><%# FormatDateTime(Eval("SubmissionDate"), DateFormat.ShortDate) %></span>
                                    </div>
                                </div>
                                <span class="badge bg-success badge-sm mt-1">
                                    <i class="bi bi-check-circle me-1"></i>Done
                                </span>
                            </div>
                        </div>

                        <div class="card-body">
                            <div class="row g-1">
                                <div class="col-md-8">
                                    <!-- ULTRA COMPACT Domain Scores Table -->
                                    <div class="table-responsive">
                                        <table class="table table-bordered table-sm table-compact mb-0">
                                            <thead class="table-light d-none d-sm-table-header-group">
                                                <tr>
                                                    <th style="width: 40%">Domain</th>
                                                    <th style="width: 15%">Weight</th>
                                                    <th style="width: 22%">Rating</th>
                                                    <th style="width: 23%">Score</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <asp:Repeater ID="rptDomains" runat="server">
                                                    <ItemTemplate>
                                                        <tr>
                                                            <td data-label="Domain" class="compact-text-sm">
                                                                <i class="bi bi-book me-1 text-primary"></i>
                                                                <span><%# Eval("DomainName") %></span>
                                                            </td>
                                                            <td data-label="Weight" class="compact-text-sm"><%# Eval("Weight") %>%</td>
                                                            <td class="score-cell <%# GetScoreClass(Convert.ToDouble(Eval("Score"))) %> compact-text-sm" data-label="Rating">
                                                                <div class="actual-score"><%# String.Format("{0:0.00}", Eval("Score")) %></div>
                                                            </td>
                                                            <td class="fw-bold <%# GetScoreClass(Convert.ToDouble(Eval("Score"))) %> compact-text-sm" data-label="Score">
                                                                <%# String.Format("{0:0.00}", Eval("WeightedScore")) %>/<%# Eval("Weight") %>
                                                            </td>
                                                        </tr>
                                                    </ItemTemplate>
                                                </asp:Repeater>
                                            </tbody>
                                            <tfoot class="table-active">
                                                <tr>
                                                    <th colspan="3" class="text-end d-none d-sm-table-cell compact-text-sm">Total</th>
                                                    <td id="totalScoreCell" runat="server" class="fw-bold compact-text-sm" data-label="Total">
                                                        <div class="actual-score"><%# String.Format("{0:0.00}", Eval("TotalScore")) %>/100</div>
                                                    </td>
                                                </tr>
                                            </tfoot>
                                        </table>
                                    </div>
                                </div>
                                
                                <div class="col-md-4 rating-breakdown">
                                    <!-- ULTRA COMPACT Overall Rating -->
                                    <div class="total-score-box">
                                        <div class="compact-text-sm text-muted mb-0">SCORE</div>
                                        <div class="fw-bold text-primary mb-0" style="font-size: 1rem;">
                                            <%# String.Format("{0:0.00}", Eval("TotalScore")) %>%
                                        </div>
                                        <span class="badge <%# GetRatingBadgeClass(Convert.ToDouble(Eval("TotalScore"))) %> score-badge">
                                            <%# GetRatingCategory(Convert.ToDouble(Eval("TotalScore"))) %>
                                        </span>
                                    </div>

                                    <!-- ULTRA COMPACT Comment Boxes -->
                                    <div class="comment-box strength-box">
                                        <div class="text-success compact-text-sm fw-bold mb-0">✓ Strengths</div>
                                        <div class="compact-text-sm"><%# If(String.IsNullOrEmpty(Eval("Strengths").ToString()), "None", Eval("Strengths")) %></div>
                                    </div>

                                    <div class="comment-box weakness-box">
                                        <div class="text-warning compact-text-sm fw-bold mb-0">⚠ Improve</div>
                                        <div class="compact-text-sm"><%# If(String.IsNullOrEmpty(Eval("Weaknesses").ToString()), "None", Eval("Weaknesses")) %></div>
                                    </div>

                                    <div class="comment-box message-box">
                                        <div class="text-info compact-text-sm fw-bold mb-0">💬 Message</div>
                                        <div class="compact-text-sm"><%# If(String.IsNullOrEmpty(Eval("AdditionalMessage").ToString()), "None", Eval("AdditionalMessage")) %></div>
                                    </div>
                                </div>
                            </div>

                            <!-- ULTRA COMPACT Detailed Questions Panel -->
                            <div class="mt-1">
                                <button class="btn btn-outline-primary w-100 toggle-btn" type="button" data-bs-toggle="collapse" 
                                        data-bs-target="#questionsPanel_<%# Eval("SubmissionID") %>" 
                                        aria-expanded="false" aria-controls="questionsPanel_<%# Eval("SubmissionID") %>">
                                    <i class="bi bi-list-check me-1"></i>
                                    Details
                                    <i class="bi bi-chevron-down ms-1"></i>
                                </button>
                                
                                <div class="collapse mt-1" id="questionsPanel_<%# Eval("SubmissionID") %>">
                                    <div class="card">
                                        <div class="card-header bg-light py-1">
                                            <h6 class="mb-0 compact-text"><i class="bi bi-question-circle me-1"></i>Question Details</h6>
                                        </div>
                                        <div class="card-body py-1">
                                            <asp:Repeater ID="rptQuestionDetails" runat="server" OnItemDataBound="rptQuestionDetails_ItemDataBound">
                                                <ItemTemplate>
                                                    <div class="domain-section">
                                                        <div class="domain-title compact-text">
                                                            <i class="bi bi-collection me-1"></i><%# Eval("DomainName") %>
                                                        </div>
                                                        <div class="table-responsive">
                                                            <table class="table table-bordered table-sm mb-0">
                                                                <tbody>
                                                                    <asp:Repeater ID="rptDomainQuestions" runat="server">
                                                                        <ItemTemplate>
                                                                            <tr>
                                                                                <td class="compact-text-sm" style="width: 80%">
                                                                                    <div class="question-text"><%# Eval("QuestionText") %></div>
                                                                                </td>
                                                                                <td class="text-center compact-text-sm" style="width: 20%">
                                                                                    <div class="star-rating-readonly">
                                                                                        <%# GetStarRatingHTML(Convert.ToInt32(Eval("Score"))) %>
                                                                                    </div>
                                                                                    <div class="small text-muted">(<%# Eval("Score") %>/5)</div>
                                                                                </td>
                                                                            </tr>
                                                                        </ItemTemplate>
                                                                    </asp:Repeater>
                                                                </tbody>
                                                            </table>
                                                        </div>
                                                    </div>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <!-- ULTRA COMPACT Empty State -->
            <asp:Panel ID="pnlNoEvaluations" runat="server" Visible="false">
                <div class="card">
                    <div class="card-body compact-padding">
                        <div class="empty-state">
                            <i class="bi bi-inbox display-6 text-muted mb-1"></i>
                            <h5 class="text-muted mb-1 compact-text">No Evaluations</h5>
                            <p class="text-muted mb-1 compact-text-sm">No evaluations submitted yet.</p>
                            <a href="Evaluate.aspx" class="btn btn-primary btn-sm">
                                <i class="bi bi-plus-circle me-1"></i>Evaluate
                            </a>
                        </div>
                    </div>
                </div>
            </asp:Panel>
        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>