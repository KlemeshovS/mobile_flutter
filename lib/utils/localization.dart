// lib/localization.dart
import 'package:flutter/material.dart';
import '../models/user_status.dart';

class AppLocalizations {
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'calendar_tab_title': 'Calendar',
      'stat_tab_title': 'Statistics',
      'ratings_tab_title': 'Ratings',
      'drink_log_prompt': 'What did you drink yesterday?',
      'or_sport_prompt': 'Or workout',
      'year_label': '%d',
      'error_future_date': 'Cannot change future dates',
      'OK': 'OK',
      'little': 'Little',
      'medium': 'Medium',
      'heavy': 'Heavy',
      'sport': 'Sport',
      'none': 'None',
      'little_sport': 'Little + Sport',
      'day_short': 'd.',

      // Ключи туториала
      'tutorial_title_1': 'Welcome to Wobbly!',
      'tutorial_desc_1': 'Wobbly is your personal log of wins and fails in the eternal battle: booze hound or gym rat?\n\nLet\'s find out who you really are when you\'re honest with yourself.',
      'tutorial_title_2': 'Your Drinking Adventures',
      'tutorial_desc_2': 'Be honest when you party. Three levels:\n• A little — "just... to wet my whistle"\n• Moderate — "I wasn\'t drinking alone, okay?"\n• Heavy — "who am I and where are my pants"',
      'tutorial_title_3': 'Gym Days (If Any)',
      'tutorial_desc_3': 'Long press on a day = workout logged.\n\nThat one magical day a month when you remember you pay for that gym membership.\nWe\'ll celebrate it like spotting a unicorn.',
      'tutorial_title_4': 'Stats & Badges',
      'tutorial_desc_4': 'Check your yearly drinking stats and your true identity:\n• Sober saint\n• Binge-drinking philosopher\n• Or that guy who pays for the gym but lives at the bar',
      'tutorial_title_4_new': 'Alcohol vs Sport',
      'tutorial_desc_4_new': 'See how your drinking compares to training. Unlock achievements for sobriety, streaks, and even for being a true party legend!',
      'tutorial_title_5': 'Backup Your Sins',
      'tutorial_desc_5': 'Full disclosure: I might be more of a drunk than a coder.\nSo backup your data sometimes. You know... just in case I mess things up in a coding frenzy.',
      'tutorial_next_button': 'Next',
      'tutorial_start_suffering_button': 'I\'m Ready to Face It',


      // Новые ключи для day_selection_sheet.dart
      'drink_prompt': 'Any drinking?',
      'little_label': 'A little',
      'medium_label': 'Moderate',
      'heavy_label': 'Heavy',
      'sport_prompt': 'Or worked out?',
      'sport_label': 'Sport',
      'ok_button': 'OK',

      // Новые ключи для stats_screen.dart
      'year_suffix': '',
      'select_year': 'Select year',
      'current_sober_streak': 'Current sober streak',
      'drinking_streak_days': 'Longest binge',
      'max_sober_streak': 'Longest clean',
      'total_drinking_days': 'Total drinking days',
      'total_sober_days': 'Total sober days',
      'sport_days_label': 'Workout days',
      'alcohol_label': 'Alcohol',
      'sport_label_bar': 'Sport',
      'alcohol_vs_sport_title': 'Alcohol vs Sport',

      // Новые ключи для прогресса
      'your_negative_progress_title': 'Your rock bottom 🏴‍☠️',
      'your_progress_title': 'Your personal Everest 🏔️',
      'next_negative_step_title': 'Next depth in',
      'next_step_title': 'Next step in',
      'days': 'm',
      'week_label': '7m',
      'month_label': '30m',
      'quarter_label': '90m',
      'half_year_label': '180m',
      'year_label_bar': '365m',
      'milestone_50_label': '50m',
      'milestone_100_label': '100m',
      'milestone_146_label': '146m',
      'milestone_319_label': '319m',
      'milestone_443_label': '443m',
      'negative_days_suffix': 'm',
      'positive_days_suffix': 'm',

      // Новые ключи для календаря
      'monday_short': 'Mo',
      'tuesday_short': 'Tu',
      'wednesday_short': 'We',
      'thursday_short': 'Th',
      'friday_short': 'Fr',
      'saturday_short': 'Sa',
      'sunday_short': 'Su',
      'january': 'January',
      'february': 'February',
      'march': 'March',
      'april': 'April',
      'may': 'May',
      'june': 'June',
      'july': 'July',
      'august': 'August',
      'september': 'September',
      'october': 'October',
      'november': 'November',
      'december': 'December',

      // Новые ключи для меню
      'menu_language': 'Language',
      'menu_language_subtitle': 'App language',
      'language_english': 'English',
      'language_russian': 'Russian',
      'language_current': 'Current',
      'switch_to_english': 'Switch to English',
      'switch_to_russian': 'Switch to Russian',
      'settings_menu': 'Settings',
      'menu_export_title': 'Export Statistics',
      'menu_export_subtitle': 'Save Backup',
      'menu_import_title': 'Import from File',
      'menu_import_subtitle': 'Load Data from File',
      'menu_restore_title': 'Restore Data',
      'export_success': 'Data exported successfully',
      'import_success': 'Data imported successfully',
      'import_error': 'Import failed',
      'menu_restore_subtitle': 'From Automatic Backup',
      'menu_reset_title': 'Reset Achievements',
      'menu_reset_subtitle': 'If you decided to cheat yourself, then changed your mind',
      'menu_tg_title': 'Write in Telegram',
      'menu_achievements_title': 'Achievements',
      'menu_version_title': 'Version',
      'about': 'About',
      'back': 'Back',
      'WOBBLY': 'WOBBLY',
      'subtitle': 'Your Journal of Triumphs and Struggles',
      'app_origin_story_part1': 'Wobbly was born from my own constant inner battle: am I more of an alcoholic or an athlete?',
      'app_origin_story_part2': 'Every day presents a choice: the clear-headed high of a good workout, or the fleeting buzz of a beer. Wobbly helps you track that choice, see the truth, and ultimately discover who you want to be.',
      'about_creator_description': 'The creator, who still doesn\'t know whether to be proud or to cry.',
      'about_capabilities_title': 'App Capabilities',
      'feature_stats_title': 'Detailed Statistics',
      'feature_stats_desc': 'Mark the day you drink and the day you exercise (long press)',
      'feature_achievements_title': 'Achievements',
      'feature_achievements_desc': 'Earn awards for sobriety',
      'feature_privacy_title': 'Privacy',
      'feature_privacy_desc': 'All data is stored only on your device. You can export and import it at any time.',
      'achievements_reset_notification_title': 'Achievements Reset',
      'achievements_reset_notification_message': 'All achievements have been unlocked again based on current data',
      'exportShareSubject': 'Wobbly Data Export',
      'exportShareText': 'Here is my Wobbly data export file.',
      'exportError': 'Export failed',

      // Новые ключи для статусов
      'status_sporty_title': 'Friendly Athlete',
      'status_sporty_description': 'You prefer sneakers to wine glasses, but sometimes allow yourself a \'sports\' beer after a workout!',
      'status_alcoholic_title': 'Professional Hangover',
      'status_alcoholic_description': 'Your liver is crying, but you stubbornly ignore its pleas. The bartender knows you by name, and the morning starts with the question "what happened yesterday?"',
      'status_boring_title': 'Boring as a Cork',
      'status_boring_description': 'You\'ve found the perfect balance between doing nothing and pretending to do something. Master of boring perfection!',
      'status_balanced_title': 'Moderate and Boring',
      'status_balanced_description': 'You drink just enough to not have fun, and exercise just enough to see no results. Perfect!',
      'status_moderate_drinker_title': 'Weekend Sinner',
      'status_moderate_drinker_description': 'You drink just enough not to feel guilty, but enough to justify your existence. The art of petty sin.',
      'status_active_lifestyle_title': 'Fitness Martyr',
      'status_active_lifestyle_description': 'You voluntarily suffer in the gym so you can suffer from a hangover with a clear conscience. The circle of torment is complete!',
      'status_weekend_warrior_title': 'Saturday Hero',
      'status_weekend_warrior_description': 'From Monday to Friday you are a model of virtue, on Saturday you are a neighborhood legend, on Sunday you are a helpless body.',
      'status_sober_enthusiast_title': 'Sober Sadist',
      'status_sober_enthusiast_description': 'You run from alcohol faster than from responsibility. The gym is your refuge from reality and parties.',
      'status_sports_fanatic_title': 'Slave of the Iron Temple',
      'status_sports_fanatic_description': 'You worship iron idols, sacrificing your time, strength, and ability to walk normally the next day. Cult of pain!',
      'status_party_animal_title': 'Party Legend',
      'status_party_animal_description': 'Your party exploits become legends, and your morning suffering becomes epic poems. Hero of Saturday night and victim of Sunday morning!',
      'status_alco_cyborg_title': 'AlcoCyborg',
      'status_alco_cyborg_description': 'A cyborg who doesn\'t drink is just scrap metal',

      // Мотивационные фразы для алкогольных дней
      'motivation_drinking_1': 'Your wallet isn\'t elastic. Your bank balance is at rock bottom, just like you were yesterday.',
      'motivation_drinking_2': 'Your liver has already sent out an SOS. Maybe give it a day off?',
      'motivation_drinking_3': 'Your liver is crying. You\'re not, because you\'re dehydrated.',
      'motivation_drinking_4': 'Your blood alcohol level is already higher than your IQ',
      'motivation_drinking_5': 'You\'re not drinking — the drink is drinking you. Take back the reins',
      'motivation_drinking_6': 'Your body is already on strike. Do you want it to file for resignation?',
      'motivation_drinking_7': 'Breakfast of Citramon and shame — is that your signature recipe? Let\'s try a new one.',
      'motivation_drinking_8': 'You\'ve blown all your cash and your health. Congrats, you\'re the proud sponsor of your own hangover.',
      'motivation_drinking_9': 'Wallet empty, head pounding, vision blurry. Just a regular weekend, huh?',
      'motivation_drinking_10': 'Your morning ritual: "Where am I?", "Who am I?", "Why?". Just like a Buddhist monk, but without the enlightenment.',
      'motivation_drinking_11': 'Your brain is already seeking political asylum in another head',
      'motivation_drinking_12': 'You\'ve crossed every line. Even the "totally wasted" line. Welcome to the binge!',
      'motivation_drinking_13': 'You\'re drinking away not just your money, but your face too. Soon your passport photo will be scarier than real life.',
      'motivation_drinking_14': 'Yesterday\'s motto: "Drink to the bottom!" And you did. Even the bottom filed a complaint about you.',
      'motivation_drinking_15': 'Yesterday you conducted a sociological study: "How people live without brains." Today it\'s time for conclusions.',
      'motivation_drinking_16': 'Went all out again? Tomorrow your clear head will thank you. Or not.',
      'motivation_drinking_17': 'Check out the calendar. This one\'s "totally wasted," this one\'s not. Which do you like better?',

      // Мотивационные заголовки
      'motivation_title_none': 'Sober Day',
      'motitle_sport': 'Sport Day',
      'motitle_little': 'Just a Sip',
      'motitle_little_sport': 'Sip + Gym',
      'motitle_medium': 'Tipsy',
      'motitle_heavy': 'Wasted',

      // Мотивационные фразы для трезвых дней
      'motivation_sober_1': 'You\'re not getting wasted, you\'re enjoying life. Others don\'t have the strength for that.',
      'motivation_sober_2': 'You\'re not a loser who can\'t afford it. You\'re a king who can, but chooses not to.💪',
      'motivation_sober_3': 'Your morning routine: waking up, not surviving. Victory.',
      'motivation_sober_4': 'Many in your place would have cracked. But you\'re handling the pressure and the glasses.',
      'motivation_sober_5': 'You didn\'t drink, which means tomorrow you\'ll wake up with only one pain — existential.',
      'motivation_sober_6': 'While everyone\'s chilling in the bathroom, you\'re chilling in life. The win is obvious.',
      'motivation_sober_7': 'You\'re not boring, you\'re sane. It\'s the new black, others just aren\'t in the loop.',
      'motivation_sober_8': 'You have plans in the morning, they have a sentence. Feel the difference?',
      'motivation_sober_9': 'You\'re not poisoning yourself with crap. Looks like your self-preservation instinct kicked in. Nice one.',
      'motivation_sober_10': 'While they\'re flushing cash down the toilet, you\'re saving up for something awesome. Who\'s winning?',
      'motivation_sober_11': 'Look at that, you\'ve got money in your wallet. Probably multiplied while you weren\'t drinking.',
      'motivation_sober_12': 'Your calendar is clean of shame. Looks suspicious... Maybe you just forgot to mark it?',
      'motivation_sober_13': 'You\'ve saved so much on alcohol that now you can buy yourself... one good sock. Life\'s looking up!',
      'motivation_sober_14': 'You\'ve got a clear head and a full wallet in the morning. Looking suspiciously successful.',
      'motivation_sober_15': 'You\'ve got an extra thousand in your pocket and extra years in reserve. What are you gonna do?',

      // Статистика – всплывающие подсказки
      'stat_sober_streak_title': 'Still not drinking?',
      'stat_sober_streak_description': 'Every sober day is an extra wrinkle on your liver that it gratefully smooths out',
      'stat_drinking_streak_title': 'Longest drinking streak',
      'stat_drinking_streak_description': 'Your personal record for testing liver\'s tensile strength. Let\'s keep it as a reminder.',
      'stat_max_sober_streak_title': 'Best sober streak',
      'stat_max_sober_streak_description': 'Peak level of your adequacy. Aim for new heights while you still remember how it felt.',
      'stat_total_drinking_days_title': 'Total drinking days',
      'stat_total_drinking_days_description': 'Counter of visited dimensions. Reminder: our dimension can be fun too.',
      'stat_total_sober_days_title': 'Total sober days',
      'stat_total_sober_days_description': 'When you remembered going to bed. Cherish those moments of clarity!',
      'stat_drink_level_little_title': 'Light drinking days',
      'stat_drink_level_little_description': 'Light artillery preparation before... nothing. A strange tactical move.',
      'stat_drink_level_medium_title': 'Moderate drinking days',
      'stat_drink_level_medium_description': 'A series of successful controlled falls. The main thing is not to turn into an uncontrolled nosedive.',
      'stat_drink_level_heavy_title': 'Heavy drinking days',
      'stat_drink_level_heavy_description': 'When you voluntarily participated in a survival experiment under conditions of severe dehydration and intoxication',
      'stat_sport_days_title': 'Workout days',
      'stat_sport_days_description': 'Number of days when you chose sweat and endorphins over sweat and shakes. Wise choice!',

      // Статистика – факты
      'your_progress': 'Your progress',
      'sober_days_count': 'Sober days:',
      'evolution_of_sober_person_title': 'Evolution of a sober person',
      'all_milestones_screen_title': 'Sobriety Milestones',
      'current_label': 'Current',

      'milestone_2d_title': '2 days',
      'milestone_3d_title': '3 days',
      'milestone_1w_title': '1 week',
      'milestone_2w_title': '2 weeks',
      'milestone_1m_title': '1 month',
      'milestone_2m_title': '2 months',
      'milestone_3m_title': '3 month',
      'milestone_6m_title': 'half year',
      'milestone_1y_title': '1 year',

      'fact_48h_1': 'Body detoxification has begun',
      'fact_48h_2': 'Blood sugar levels are normalizing',
      'fact_48h_3': 'Hydration is improving',
      'fact_48h_4': 'Liver load is decreasing',
      'fact_48h_5': 'Heart rate is normalizing',

      'fact_48h_full_1': 'Body detoxification begins',
      'fact_48h_full_2': 'Blood sugar levels normalize',
      'fact_48h_full_3': 'Tissue hydration improves',
      'fact_48h_full_4': 'Liver load decreases',
      'fact_48h_full_5': 'Heart rhythm normalizes',
      'fact_48h_full_6': 'Inflammation levels decrease',

      'fact_3d_1': 'Sleep has normalized (REM phase)',
      'fact_3d_2': 'Skin hydration has improved',
      'fact_3d_3': 'Headaches have subsided',
      'fact_3d_4': 'Toxin levels have decreased',
      'fact_3d_5': 'Mood has improved',

      'fact_3d_full_1': 'Sleep normalizes (REM phase restores)',
      'fact_3d_full_2': 'Skin hydration improves',
      'fact_3d_full_3': 'Headaches disappear',
      'fact_3d_full_4': 'Blood toxin levels decrease',
      'fact_3d_full_5': 'Mood improves and anxiety decreases',
      'fact_3d_full_6': 'Nervous system restoration begins',

      'fact_week_1': 'Liver is 15-20% restored',
      'fact_week_2': 'Digestion has improved',
      'fact_week_3': 'Blood pressure has normalized',
      'fact_week_4': 'Skin hydration is restored',
      'fact_week_5': 'Inflammation levels have decreased',

      'fact_week_full_1': 'Liver is 15-20% restored',
      'fact_week_full_2': 'Digestion and metabolism improve',
      'fact_week_full_3': 'Blood pressure normalizes',
      'fact_week_full_4': 'Skin hydration restores',
      'fact_week_full_5': 'Systemic inflammation decreases',
      'fact_week_full_6': 'Sleep quality improves by 40%',

      'fact_2w_1': 'Concentration has improved',
      'fact_2w_2': 'Anxiety has decreased',
      'fact_2w_3': 'Skin has become clearer',
      'fact_2w_4': 'Sugar levels have normalized',
      'fact_2w_5': 'Sleep quality has improved',

      'fact_2w_full_1': 'Concentration and focus improve',
      'fact_2w_full_2': 'Anxiety and irritability decrease',
      'fact_2w_full_3': 'Skin becomes clearer, breakouts reduce',
      'fact_2w_full_4': 'Blood sugar levels normalize',
      'fact_2w_full_5': 'Sleep improves (all phases)',
      'fact_2w_full_6': 'Cognitive function restoration begins',

      'fact_month_1': 'Liver is 40-50% restored',
      'fact_month_2': 'Risk of heart disease has decreased',
      'fact_month_3': 'Immunity has improved',
      'fact_month_4': 'Blood pressure has normalized',
      'fact_month_5': 'Digestion has improved',

      'fact_month_full_1': 'Liver is 40-50% restored',
      'fact_month_full_2': 'Heart disease risk decreases by 15%',
      'fact_month_full_3': 'Immune function improves',
      'fact_month_full_4': 'Blood pressure normalizes',
      'fact_month_full_5': 'Digestion and nutrient absorption improve',
      'fact_month_full_6': 'Cholesterol levels decrease',

      'fact_2m_1': 'Brain function improved by 30%',
      'fact_2m_2': 'Weight has normalized',
      'fact_2m_3': 'Diabetes risk decreased by 25%',
      'fact_2m_4': 'Blood circulation has improved',
      'fact_2m_5': 'Anxiety has decreased',

      'fact_2m_full_1': 'Brain function improves by 30%',
      'fact_2m_full_2': 'Weight and body composition normalize',
      'fact_2m_full_3': 'Type 2 diabetes risk decreases by 25%',
      'fact_2m_full_4': 'Blood circulation and tissue oxygenation improveй',
      'fact_2m_full_5': 'Anxiety decreases and mental health improves',
      'fact_2m_full_6': 'Libido and hormonal balance restore',

      'fact_3m_1': 'Liver is 60-70% restored',
      'fact_3m_2': 'Hormonal balance has normalized',
      'fact_3m_3': 'Sleep quality has improved',
      'fact_3m_4': 'Cholesterol levels have decreased',
      'fact_3m_5': 'Skin condition has improved',

      'fact_3m_full_1': 'Liver is 60-70% restored',
      'fact_3m_full_2': 'Hormonal balance normalizes',
      'fact_3m_full_3': 'Sleep quality improves by 80%',
      'fact_3m_full_4': 'LDL cholesterol levels decrease',
      'fact_3m_full_5': 'Skin, hair, and nail condition improve',
      'fact_3m_full_6': 'Gut microbiome restores',

      'fact_6m_1': 'Liver is 70-80% restored',
      'fact_6m_2': 'Liver cancer risk reduced by 50%',
      'fact_6m_3': 'Sleep fully restored (all phases)',
      'fact_6m_4': 'Memory and concentration improved',
      'fact_6m_5': 'Type 2 diabetes risk decreased',

      'fact_6m_full_1': 'Liver is 70-80% restored',
      'fact_6m_full_2': 'Liver cancer risk reduced by 50%',
      'fact_6m_full_3': 'Sleep fully restores (all phases)',
      'fact_6m_full_4': 'Memory and concentration improve by 60%',
      'fact_6m_full_5': 'Type 2 diabetes risk decreases by 40%',
      'fact_6m_full_6': 'Mental health normalizes',

      'fact_year_1': 'Liver is 90-95% restored',
      'fact_year_2': 'Heart disease risk reduced by 50%',
      'fact_year_3': 'All blood markers normalized',
      'fact_year_4': 'Stroke risk reduced by 40%%',
      'fact_year_5': 'Liver and pancreatic cancer risk significantly reduced',

      'fact_year_full_1': 'Liver is 90-95% restored',
      'fact_year_full_2': 'Heart disease risk reduced by 50%',
      'fact_year_full_3': 'All blood markers normalized',
      'fact_year_full_4': 'Stroke risk reduced by 40%',
      'fact_year_full_5': 'Liver and pancreatic cancer risk significantly reduced',
      'fact_year_full_6': 'Complete restoration of cognitive functions',

      'hangover_title_1': 'Yesterday was tough?',
      'hangover_title_2': 'Hangover? Remember:',
      'hangover_title_3': 'Your body is recovering',
      'hangover_title_4': 'Time to get back on track',
      'hangover_title_5': 'Every day is a new start',
      'hangover_title_6': 'You\'ve got this',
      'hangover_title_7': 'Small steps, big results',
      'hangover_title_8': 'Your future self thanks you',
      'hangover_title_9': 'Choose progress',
      'hangover_title_10': 'One day at a time',

      'hangover_1_point_1': 'Your brain is still recovering',
      'hangover_1_point_2': 'Hydration is key',
      'hangover_1_point_3': 'Save money today',
      'hangover_2_point_1': 'Alcohol disrupts sleep',
      'hangover_2_point_2': 'Your focus improves without it',
      'hangover_2_point_3': 'Heart rate normalizes',
      'hangover_3_point_1': 'Cognitive function returns',
      'hangover_3_point_2': 'You are the king of your life',
      'hangover_3_point_3': 'Productivity is rising',
      'hangover_4_point_1': 'Math gets easier',
      'hangover_4_point_2': 'Mornings are brighter',
      'hangover_4_point_3': 'Unlock new potential',
      'hangover_5_point_1': 'Less heart strain',
      'hangover_5_point_2': 'Eyes become clearer',
      'hangover_5_point_3': 'Breathing deepens',
      'hangover_6_point_1': 'Energy levels stabilize',
      'hangover_6_point_2': 'You are on the right track',
      'hangover_6_point_3': 'Health is recovering',
      'hangover_7_point_1': 'Body resets itself',
      'hangover_7_point_2': 'Sleep quality improves',
      'hangover_7_point_3': 'Motivation gauge fills up',
      'hangover_8_point_1': 'Better communication',
      'hangover_8_point_2': 'Movement becomes easier',
      'hangover_8_point_3': 'Celebrate small wins',
      'hangover_9_point_1': 'No wasted money',
      'hangover_9_point_2': 'Savings grow',
      'hangover_9_point_3': 'Treat yourself instead',
      'hangover_10_point_1': 'Weight stabilizes',
      'hangover_10_point_2': 'Bright ideas come',
      'hangover_10_point_3': 'You are winning',

      // НОВЫЕ КЛЮЧИ ДЛЯ ДОСТИЖЕНИЙ
      'achievements': 'Achievements',
      'all_achievements': 'All',
      'ach_drink_3_title': 'Survival Pro',
      'ach_drink_3_desc': 'Three days in a row in the dark? Survived? You\'re a professional.',
      'ach_drink_7_title': 'Master of Morning Shame',
      'ach_drink_7_desc': '7 days non-stop? Your liver has already sent an SOS signal.',
      'ach_drink_14_title': 'Patron of the Alcohol Industry',
      'ach_drink_14_desc': 'Every weekend you sponsor someone\'s yacht',
      'ach_drink_30_title': 'Morning Survival Expert',
      'ach_drink_30_desc': 'You know 1001 ways to come back to life in the morning',

      'ach_sober_7_title': 'Stingy Knight',
      'ach_sober_7_desc': 'Your wallet is fat, and your head is clear',
      'ach_sober_14_title': 'Liver on Vacation',
      'ach_sober_14_desc': 'Your liver has finally gone to a spa',
      'ach_sober_21_title': 'Enemy of Local Bars',
      'ach_sober_21_desc': 'Bartenders cry into empty glasses when they see you',
      'ach_sober_30_title': 'King of Sober Mornings',
      'ach_sober_30_desc': 'You remember going to bed. And getting up. And everything in between.',
      'ach_sober_60_title': 'Threat to the Alcohol Industry',
      'ach_sober_60_desc': 'Your sobriety scares the producers',
      'ach_sober_90_title': 'Self-Control: God Level',
      'ach_sober_90_desc': 'You keep yourself together even when everyone else is losing their heads',
      'ach_sober_180_title': 'Your Own Detox Center',
      'ach_sober_180_desc': 'Saved a ton of money on IV drips',
      'ach_sober_365_title': 'Master of Your Own Brain',
      'ach_sober_365_desc': 'Your brain finally produces dopamine on its own',

      'ach_sport_8_title': 'Fitness Victim',
      'ach_sport_8_desc': 'You voluntarily pay money for the right to experience pain!',
      'ach_sport_12_title': 'Fitness Maniac',
      'ach_sport_12_desc': 'Muscle soreness has become your constant companion!',
      'ach_sport_50_title': 'Sufferer',
      'ach_sport_50_desc': 'Your body constantly hurts somewhere, but you call it "progress"',
      'ach_sport_100_title': 'Self-Torture Guru',
      'ach_sport_100_desc': 'Sadistic pleasure from pain has become your life\'s meaning!',

      'condition_drinking_days': '%1 days in a row',
      'condition_sober_days': '%1 sober days in a row',
      'condition_sport_count': '%1 workouts in %2 days',
      'condition_sober_new_year': 'Spend December 31 without alcohol',
      'condition_sport_new_year': 'Work out on December 31',

      'ach_milestone_146_title': 'Great Pyramid of Giza',
      'ach_milestone_146_desc': 'Tens of thousands of slaves built this without water or whiskey. You just climbed it.',
      'ach_milestone_319_title': 'Chrysler Building',
      'ach_milestone_319_desc': 'The spire is sharper than your craving for a drink.',
      'ach_milestone_443_title': 'Empire State Building',
      'ach_milestone_443_desc': 'King Kong climbed it for a blonde. You did it for an achievement and zero drinks.',
      'ach_milestone_1234_title': 'Ai-Petri',
      'ach_milestone_1234_desc': 'You climbed, sweated, stayed sober. The reward? A view of Yalta. Worth it?',
      'ach_milestone_4810_title': 'Mont Blanc',
      'ach_milestone_4810_desc': 'Sport, sobriety, discipline. You made it to the top. Where\'s the champagne? Oh right, not allowed.',
      'ach_milestone_5642_title': 'Elbrus',
      'ach_milestone_5642_desc': 'So many weeks sober, mountain lungs. Little oxygen, but a clear conscience.',
      'ach_milestone_7010_title': 'Khan Tengri',
      'ach_milestone_7010_desc': 'Only the sky is higher. But there\'s no bar there either. At least the view\'s nice.',
      'ach_milestone_8848_title': 'Everest',
      'ach_milestone_8848_desc': 'You\'re on top of the world. Could have just stayed sober for six months. Just kidding, well done!',


      //Ачивки для погружения
      'ach_milestone_202_negative_title': 'The Blue Hole',
      'ach_milestone_202_negative_desc': 'Narrow, deep, dark. Just like your life after Friday.',
      'ach_milestone_1642_negative_title': 'Lake Baikal',
      'ach_milestone_1642_negative_desc': 'The deepest freshwater lake. Your body is now fresh. And dead. И мёртвый.',
      'ach_milestone_3800_negative_title': 'The Titanic',
      'ach_milestone_3800_negative_desc': 'Titanic\'s icy grave. And yours - in progress.',
      'ach_milestone_6066_negative_title': 'Atacama Trench',
      'ach_milestone_6066_negative_desc': 'The Ring of Fire. Your liver is now at the epicenter too.',
      'ach_milestone_10047_negative_title': 'Kermadec Trench',
      'ach_milestone_10047_negative_desc': 'The deep-sea robot Nereus got crushed here. But you? Tough nut.',
      'ach_milestone_11022_negative_title': 'Mariana Trench',
      'ach_milestone_11022_negative_desc': 'You\'re at the bottom. Literally. It can\'t get worse. Or can it?',

      'condition_milestone_positive': '%1 meters above sea level',
      'condition_milestone_negative': '%1 meters under water',

      'no_achievements_yet': 'No achievements yet',

      //Окно оценки
      'review_title': 'Enjoying Wobbly?',
      'review_message': 'You\'ve spent ages filling the calendar – don\'t be a pig, drop a star at Google Play. If it sucks – hit 1 star, we\'ll fix it.',
      'review_rate_button': 'Rate App',
      'review_later_button': 'Later',
      'review_later_message': 'I\'ll be back',

      // Рейтинги и профиль
      'ratings_tab_title': 'Ratings',
      'top_100': 'Temperance Titans',
      'bottom_100': 'Liquid Legends',
      'menu_user_profile': 'Profile',
      'menu_user_profile_subtitle': 'Name and rating participation',
      'user_name_label': 'Your name',
      'user_ranking_toggle': 'Participate in ratings',
      'save_button': 'Save',
      'error_username_empty': 'Name cannot be empty',
      'error_username_too_short': 'Minimum 3 characters',
      'error_username_too_long': 'Maximum 20 characters',
      'error_username_already_exists': 'This name is already taken',
      'error_missing_token': 'Authorization error',
      'error_unauthorized': 'Authorization error',
      'error_username_invalid_characters': 'Username contains invalid characters. Only letters, numbers, underscores and hyphens are allowed.',
      'error_username_contains_space':'Username cannot contain spaces',
      'no_internet':'No internet connection. Please check your network.',
      'profile_needed': 'To view ratings, set up your profile',
      'setup_profile': 'Set up profile',
      'retry': 'Retry',
      'no_leaderboard_data': 'No data available',
      'rating_not_participating': 'You are not participating in the ratings',
      'rating_participate_button': 'Participate',
// Попапы топ-3 (верх)
      'top_1_place_title': 'King of the Hill',
      'top_1_place_description': 'You\'re on top! But remember: the higher you climb, the harder you fall.',
      'top_2_place_title': 'Silver Medalist',
      'top_2_place_description': 'Almost there. Just a little more and you\'ll be first... or not.',
      'top_3_place_title': 'Bronze Contender',
      'top_3_place_description': 'You\'re in the top three. Next stop — the podium.',
// Попапы дна-3 (низ)
      'bottom_1_place_title': 'Alcogodzilla',
      'bottom_1_place_description': 'You\'re number one in the most dubious ranking. Proud?',
      'bottom_2_place_title': 'Bacchus\'s Faithful Companion',
      'bottom_2_place_description': 'You\'re almost the champion of libations. Just a bit more',
      'bottom_3_place_title': 'Bronze Reveler',
      'bottom_3_place_description': 'You\'re in the top three toughest alcohol tourists. Here\'s your cup, you\'ll need it.',
// Туториал – страница профиля
      'tutorial_title_profile': 'Ranking preferences',
      'tutorial_desc_profile': 'If you want to know who’s climbing the peaks or hitting rock bottom, join the rankings!',
      'profile_guest_title': 'Not logged in',
      'profile_guest_message': 'Sign in with Google to participate in ratings and save your progress.',

    },
    'ru': {
      'calendar_tab_title': 'Календарь',
      'stat_tab_title': 'Статистика',
      'ratings_tab_title': 'Рейтинги',
      'drink_log_prompt': 'Что выпил вчера?',
      'or_sport_prompt': 'Или тренировка',
      'year_label': '%d',
      'error_future_date': 'Нельзя изменить будущие даты',
      'OK': 'OK',
      'little': 'Мало',
      'medium': 'Средне',
      'heavy': 'Много',
      'sport': 'Спорт',
      'none': 'Нет',
      'little_sport': 'Мало + Спорт',
      'day_short': 'д.',

      // Ключи туториала
      'tutorial_title_1': 'Добро пожаловать',
      'tutorial_desc_1': 'Wobbly — это дневник твоих побед и поражений в вечной битве: ты алкоголик или спортсмен?\n\nПриложение покажет, кто ты на самом деле.',
      'tutorial_title_2': 'Твои алкоподвиги',
      'tutorial_desc_2': 'Честно отмечай, когда бухаешь. Три градации:\n• Чучуть — «ну так... для аппетита»\n• Средне — «ну я же не один бухал»\n• Всрало — «кто я и где мои штаны»',
      'tutorial_title_3': 'Спортивные дни',
      'tutorial_desc_3': 'Долгое нажатие на день = спорт.\n\nТот один день в месяце, когда ты вспоминаешь, что платишь за спортзал.\nМы обязательно это отметим. Как редкое астрономическое явление.',
      'tutorial_title_4': 'Статистика и ачивки',
      'tutorial_desc_4': 'Смотри сколько ты пил за год и кто ты по жизни:\n• Трезвый праведник\n• Запойный философ\n• Или тот парень, который платит за спортзал, но ходит только в бар',
      'tutorial_title_4_new': 'Алкоголь или Спорт',
      'tutorial_desc_4_new': 'Смотри соотношение выпитого и тренировок. Получай достижения за трезвость, запои и даже за то, что ты настоящая легенда вечеринки!',
      'tutorial_title_5': 'Сохраняй свои грехи',
      'tutorial_desc_5': 'Признаюсь: я больше алкоголик, чем программист.\nПоэтому иногда экспортируй данные. Мало ли - вдруг я всё сломаю в пьяном угаре.',
      'tutorial_next_button': 'Дальше',
      'tutorial_start_suffering_button': 'Начать страдать',

      // Новые ключи для day_selection_sheet.dart
      'drink_prompt': 'Бухал?',
      'little_label': 'Чучуть',
      'medium_label': 'Средне',
      'heavy_label': 'Всрало',
      'sport_prompt': 'Или тренировался?',
      'sport_label': 'Спорт',
      'ok_button': 'OK',

      // Новые ключи для stats_screen.dart
      'year_suffix': 'год',
      'select_year': 'Выберите год',
      'current_sober_streak': 'Уже не пью',
      'drinking_streak_days': 'Дней в запое',
      'max_sober_streak': 'Максимум не пил',
      'total_drinking_days': 'Бухих дней',
      'total_sober_days': 'Трезвых дней',
      'sport_days_label': 'Спортивных дней',
      'alcohol_label': 'Алкоголь',
      'sport_label_bar': 'Спорт',
      'alcohol_vs_sport_title': 'Алкоголь vs Спорт',

      // Новые ключи для прогресса
      'your_negative_progress_title': 'Твое личное дно 🏴‍☠️',
      'your_progress_title': 'Твой личный Эверест 🏔️',
      'next_negative_step_title': 'Следующая глубина через',
      'next_step_title': 'Следующая высота через',
      'days': 'м',
      'week_label': '7м',
      'month_label': '30м',
      'quarter_label': '90м',
      'half_year_label': '180м',
      'year_label_bar': '365м',
      'milestone_50_label': '50м',
      'milestone_100_label': '100м',
      'milestone_146_label': '146м',
      'milestone_319_label': '319м',
      'milestone_443_label': '443м',

      'negative_days_suffix': 'м',
      'positive_days_suffix': 'м',

      // Новые ключи для календаря
      'monday_short': 'Пн',
      'tuesday_short': 'Вт',
      'wednesday_short': 'Ср',
      'thursday_short': 'Чт',
      'friday_short': 'Пт',
      'saturday_short': 'Сб',
      'sunday_short': 'Вс',
      'january': 'Январь',
      'february': 'Февраль',
      'march': 'Март',
      'april': 'Апрель',
      'may': 'Май',
      'june': 'Июнь',
      'july': 'Июль',
      'august': 'Август',
      'september': 'Сентябрь',
      'october': 'Октябрь',
      'november': 'Ноябрь',
      'december': 'Декабрь',

      // Новые ключи для меню
      'menu_language': 'Язык',
      'menu_language_subtitle': 'Язык приложения',
      'language_english': 'English',
      'language_russian': 'Русский',
      'language_current': 'Текущий',
      'switch_to_english': 'Переключить на английский',
      'switch_to_russian': 'Переключить на русский',
      'settings_menu': 'Настройки',
      'menu_export_title': 'Экспорт статистики',
      'menu_export_subtitle': 'Сохранить резервную копию',
      'menu_import_title': 'Импорт из файла',
      'menu_import_subtitle': 'Загрузить данные из файла',
      'export_success': 'Данные сохранились',
      'import_success': 'Данные успешно импортированы',
      'import_error': 'Ошибка импорта',
      'menu_restore_title': 'Восстановить данные',
      'menu_restore_subtitle': 'Из автоматического бэкапа',
      'menu_reset_title': 'Сбросить ачивки',
      'menu_reset_subtitle': 'Если вы решили обмануть себя, а потом передумали',
      'menu_tg_title': 'Написать в Telegram',
      'menu_achievements_title': 'Достижений',
      'menu_version_title': 'Версия',
      'about': 'О приложении',
      'back': 'Назад',
      'WOBBLY': 'WOBBLY',
      'subtitle': 'Твой дневник побед и поражений',
      'app_origin_story_part1': 'Wobbly родился из моего вечного спора с самим собой: я больше алкоголик или спортсмен?',
      'app_origin_story_part2': 'Каждый день выбираю между кайфом от тренировки и кайфом от пива. Это приложение помогает посмотреть правде в глаза и понять, кто же ты на самом деле.',
      'about_creator_description': 'Создатель, который сам не знает, гордиться ему или плакать',
      'about_capabilities_title': 'Возможности приложения',
      'feature_stats_title': 'Подробная статистика',
      'feature_stats_desc': 'Отмечай день, когда ты пьешь и когда занимаешься спортом (долгое нажатие)',
      'feature_achievements_title': 'Достижения',
      'feature_achievements_desc': 'Зарабатывай награды при воздержании',
      'feature_privacy_title': 'Конфиденциальность',
      'feature_privacy_desc': 'Все данные хранятся только на вашем устройстве. Вы можете выгружать и загружать их в любой момент.',
      'achievements_reset_notification_title': 'Ачивки сброшены',
      'achievements_reset_notification_message': 'Все достижения разблокированы заново на основе текущих данных',
      'exportShareSubject': 'Экспорт данных Wobbly',
      'exportShareText': 'Вот файл с экспортом моих данных из Wobbly.',
      'exportError': 'Ошибка экспорта',

      // Новые ключи для статусов
      'status_sporty_title': 'Любитель зарядки',
      'status_sporty_description': 'Ты больше любишь кроссовки, чем бокалы, но иногда позволяешь себе «спортивное» пиво после тренировки!',
      'status_alcoholic_title': 'КМС по алкоспорту',
      'status_alcoholic_description': 'Твоя печень плачет, но ты упорно не слышишь её мольбы. Бармен знает тебя по имени, а утро начинается с вопроса «что вчера было?».',
      'status_boring_title': 'Скучный как пробка',
      'status_boring_description': 'Твоя жизнь настолько предсказуема, что даже календарь завидует. Никаких крайностей — только стабильная скука изо дня в день.',
      'status_balanced_title': 'Ровный аж тошнит',
      'status_balanced_description': 'Ты пьёшь ровно столько, чтобы не было весело, и занимаешься спортом ровно столько, чтобы не было результата. Идеально!',
      'status_moderate_drinker_title': 'Грешник выходного дня',
      'status_moderate_drinker_description': 'Ты пьёшь ровно столько, чтобы не чувствовать вину, но достаточно, чтобы оправдать своё существование. Искусство мелкого греха.',
      'status_active_lifestyle_title': 'Фитнес-мученик',
      'status_active_lifestyle_description': 'Ты страдаешь в зале, чтобы потом с чистой совестью страдать от похмелья. Круг страданий замкнулся!',
      'status_weekend_warrior_title': 'Субботний герой',
      'status_weekend_warrior_description': 'С понедельника по пятницу ты образец добродетели, в субботу — легенда района, в воскресенье — беспомощное тело.',
      'status_sober_enthusiast_title': 'Трезвый садист',
      'status_sober_enthusiast_description': 'Ты бежишь от алкоголя быстрее, чем от ответственности. Спортзал — твоё убежище от реальности и вечеринок.',
      'status_sports_fanatic_title': 'Раб железного храма',
      'status_sports_fanatic_description': 'Ты поклоняешься железным богам, принося им в жертву своё время, силы и возможность нормально ходить после тренировок.',
      'status_party_animal_title': 'Тусовщик-легенда',
      'status_party_animal_description': 'Твои вечеринки войдут в историю, а твоё похмелье — в книгу рекордов. Ты не просто тусовщик, ты — легенда!',
      'status_alco_cyborg_title': 'Алкокиборг',
      'status_alco_cyborg_description': 'Киборг, который не пьёт — просто железка.',

      // Мотивационные заголовки
      'motivation_title_none': 'Просто не пил?',
      'motitle_sport': 'Ого, вчера был спорт',
      'motitle_little': 'Пригубил вчера',
      'motitle_little_sport': 'Классика, спорт и выпить',
      'motitle_medium': 'Значит бухал, да?',
      'motitle_heavy': 'Ого, вчера было весело',

      // Мотивационные фразы для алкогольных дней
      'motivation_drinking_1': 'Кошелёк не резиновый. Твой баланс на дне, как и ты после вчерашнего.',
      'motivation_drinking_2': 'Твоя печень уже отправила SOS. Может, дашь ей выходной?',
      'motivation_drinking_3': 'Твоя печень плачет. А ты нет, потому что обезвожен.',
      'motivation_drinking_4': 'Твой уровень алкоголя в крови уже выше, чем твой IQ',
      'motivation_drinking_5': 'Не ты бухаешь, а бухает тебя. Возьми бразды правления обратно.',
      'motivation_drinking_6': 'Твой организм уже бастует. Хочешь, чтобы он подал заявление по собственному?',
      'motivation_drinking_7': 'Завтрак из цитрамона и стыда — это твой фирменный рецепт? Давай попробуем новый.',
      'motivation_drinking_8': 'Ты просадил все бабки и здоровье. Поздравляю, ты спонсор собственного похмелья.',
      'motivation_drinking_9': 'Кошелёк пуст, голова болит, в глазах пелена. Нормальный выходной, чё.',
      'motivation_drinking_10': 'Твой утренний ритуал: «где я?», «кто я?», «за что?». Прям как у буддийского монаха, только без просветления.',
      'motivation_drinking_11': 'Твои мозги уже просят политического убежища в другой голове.',
      'motivation_drinking_12': 'Ты перешел все границы. Даже границу «всрало». Добро пожаловать в запой!',
      'motivation_drinking_13': 'Ты пропиваешь не только деньги, но и лицо. Скоро в паспорте будешь страшнее, чем в жизни.',
      'motivation_drinking_14': 'Твой вчерашний девиз: «Пить до дна!». И ты допил. Даже дно пожаловалось на тебя в администрации.',
      'motivation_drinking_15': 'Ты вчера провел социологическое исследование «Как люди живут без мозгов». Сегодня пришло время для выводов.',
      'motivation_drinking_16': 'Снова вписались на полную? Завтра голова ясная будет благодарить. Или нет.',
      'motivation_drinking_17': 'Зацени календарь. Вот это всрало, а это нет. Чё больше нравится?',

      // Мотивационные фразы для трезвых дней
      'motivation_sober_1': 'Ты не бухаешь, ты кайфуешь. Остальным на это сил не хватает.',
      'motivation_sober_2': 'Ты не лох, который не может позволить. Ты царь, который может, но не хочет.💪',
      'motivation_sober_3': 'Твой утренний режим — проснуться, а не выжить. Победа.',
      'motivation_sober_4': 'На твоём месте уже многие бы сломались. А ты держишь удар и стаканы.',
      'motivation_sober_5': 'Ты не пил, а значит, завтра ты проснешься с единственной болью — экзистенциальной',
      'motivation_sober_6': 'Пока все тусят в сортире, ты тусишь в жизни. Выигрыш очевиден.',
      'motivation_sober_7': 'Ты не скучный, ты адекватный. Это новый чёрный, остальные просто не в теме.',
      'motivation_sober_8': 'У тебя утром планы, а у них — приговор. Чувствуешь разницу?',
      'motivation_sober_9': 'Ты не травишь себя всякой дрянью. Похоже, у тебя включился инстинкт самосохранения. Красава.',
      'motivation_sober_10': 'Пока они сливают бабки в унитаз, ты копишь на что-то охуенное. Кто кого?',
      'motivation_sober_11': 'Смотри-ка, а у тебя в кошельке завелись деньги. Наверное, размножились, пока ты не бухал.',
      'motivation_sober_12': 'Твой календарь чист от позора. Выглядит подозрительно... Может, просто забыл отметить?',
      'motivation_sober_13': 'Ты сэкономил на алкоголе столько, что теперь можешь купить себе... один хороший носок. Жизнь налаживается!',
      'motivation_sober_14': 'У тебя с утра ясная голова и полный кошелёк. Выглядишь подозрительно успешным.',
      'motivation_sober_15': 'Тебя ждёт лишняя тысяча в кармане и лишние годы в запасе. Чё будешь делать?',

      // Статистика – всплывающие подсказки
      'stat_sober_streak_title': 'Все еще не пьешь?',
      'stat_sober_streak_description': 'Каждый день без алкоголя — это лишняя складка на твоей печени, которую она с благодарностью разглаживает',
      'stat_drinking_streak_title': 'Максимальная серия с алкоголем',
      'stat_drinking_streak_description': 'Твой личный рекорд по проверке прочности печени на разрыв. Давай оставим его как напоминание.',
      'stat_max_sober_streak_title': 'Лучшая серия трезвости',
      'stat_max_sober_streak_description': 'Пиковое значение твоей адекватности. Стремись к новым высотам, пока помнишь, как это было.',
      'stat_total_drinking_days_title': 'Всего дней с алкоголем',
      'stat_total_drinking_days_description': 'Счётчик посещённых измерений. Напоминание: в нашем измерении тоже бывает весело.',
      'stat_total_sober_days_title': 'Всего дней без алкоголя',
      'stat_total_sober_days_description': 'Когда ты помнил, как лег спать. Цени эти моменты ясности!',
      'stat_drink_level_little_title': 'Дни когда выпил немного',
      'stat_drink_level_little_description': 'Лёгкая артподготовка перед... ничем. Странный тактический ход.',
      'stat_drink_level_medium_title': 'Дни с умеренным употреблением',
      'stat_drink_level_medium_description': 'Серия успешных контролируемых падений. Главное — не перейти в неконтролируемое пике.',
      'stat_drink_level_heavy_title': 'Дни с сильным употреблением',
      'stat_drink_level_heavy_description': 'Когда ты добровольно становился участником эксперимента по выживанию в условиях жесточайшего обезвоживания и интоксикации',
      'stat_sport_days_title': 'Дни занятий спортом',
      'stat_sport_days_description': 'Количество дней, когда ты выбрал пот и эндорфины вместо пота и дрожи. Мудрый выбор!',


      // Статистика – факты
      'your_progress': 'Полностью сухой',
      'sober_days_count': 'Трезвых дней:',
      'evolution_of_sober_person_title': 'Эволюция трезвого человека',
      'all_milestones_screen_title': 'Рубежи трезвости',
      'current_label': 'Текущий',

      'milestone_2d_title': '2 дня',
      'milestone_3d_title': '3 дня',
      'milestone_1w_title': '1 неделя',
      'milestone_2w_title': '2 недели',
      'milestone_1m_title': '1 месяц',
      'milestone_2m_title': '2 месяца',
      'milestone_3m_title': '3 месяца',
      'milestone_6m_title': 'пол года',
      'milestone_1y_title': '1 год',

      'fact_48h_1': 'Началась детоксикация организма',
      'fact_48h_2': 'Нормализуется уровень сахара в крови',
      'fact_48h_3': 'Улучшается гидратация',
      'fact_48h_4': 'Снижается нагрузка на печень',
      'fact_48h_5': 'Нормализуется сердечный ритм',

      'fact_48h_full_1': 'Начинается детоксикация организма',
      'fact_48h_full_2': 'Нормализуется уровень сахара в крови',
      'fact_48h_full_3': 'Улучшается гидратация тканей',
      'fact_48h_full_4': 'Снижается нагрузка на печень',
      'fact_48h_full_5': 'Нормализуется сердечный ритм',
      'fact_48h_full_6': 'Снижается уровень воспаления',

      'fact_3d_1': 'Нормализовался сон (фаза REM)',
      'fact_3d_2': 'Улучшилась гидратация кожи',
      'fact_3d_3': 'Прошли головные боли',
      'fact_3d_4': 'Снизился уровень токсинов',
      'fact_3d_5': 'Улучшилось настроение',

      'fact_3d_full_1': 'Нормализуется сон (восстанавливается фаза REM)',
      'fact_3d_full_2': 'Улучшается гидратация кожи',
      'fact_3d_full_3': 'Проходят головные боли',
      'fact_3d_full_4': 'Снижается уровень токсинов в крови',
      'fact_3d_full_5': 'Улучшается настроение и снижается тревожность',
      'fact_3d_full_6': 'Начинается восстановление нервной системы',

      'fact_week_1': 'Печень восстановлена на 15-20%',
      'fact_week_2': 'Улучшилось пищеварение',
      'fact_week_3': 'Нормализовалось давление',
      'fact_week_4': 'Восстановилась гидратация кожи',
      'fact_week_5': 'Снизился уровень воспаления',

      'fact_week_full_1': 'Печень восстановлена на 15-20%',
      'fact_week_full_2': 'Улучшается пищеварение и метаболизм',
      'fact_week_full_3': 'Нормализуется артериальное давление',
      'fact_week_full_4': 'Восстанавливается гидратация кожи',
      'fact_week_full_5': 'Снижается уровень системного воспаления',
      'fact_week_full_6': 'Улучшается качество сна на 40%',

      'fact_2w_1': 'Улучшилась концентрация',
      'fact_2w_2': 'Снизилась тревожность',
      'fact_2w_3': 'Кожа стала чище',
      'fact_2w_4': 'Нормализовался уровень сахара',
      'fact_2w_5': 'Улучшился сон',

      'fact_2w_full_1': 'Улучшается концентрация и фокус',
      'fact_2w_full_2': 'Снижается тревожность и раздражительность',
      'fact_2w_full_3': 'Кожа становится чище, уменьшаются высыпания',
      'fact_2w_full_4': 'Нормализуется уровень сахара в крови',
      'fact_2w_full_5': 'Улучшается сон (все фазы сна)',
      'fact_2w_full_6': 'Начинается восстановление когнитивных функций',

      'fact_month_1': 'Печень восстановлена на 40-50%',
      'fact_month_2': 'Риск сердечных заболеваний снизился',
      'fact_month_3': 'Улучшился иммунитет',
      'fact_month_4': 'Нормализовалось давление',
      'fact_month_5': 'Улучшилось пищеварение',

      'fact_month_full_1': 'Печень восстановлена на 40-50%',
      'fact_month_full_2': 'Риск сердечных заболеваний снижается на 15%',
      'fact_month_full_3': 'Улучшается иммунная функция',
      'fact_month_full_4': 'Нормализуется кровяное давление',
      'fact_month_full_5': 'Улучшается пищеварение и усвоение питательных веществ',
      'fact_month_full_6': 'Снижается уровень холестерина',

      'fact_2m_1': 'Улучшилась работа мозга на 30%',
      'fact_2m_2': 'Нормализовался вес',
      'fact_2m_3': 'Снизился риск диабета на 25%',
      'fact_2m_4': 'Улучшилось кровообращение',
      'fact_2m_5': 'Снизилась тревожность',

      'fact_2m_full_1': 'Улучшается работа мозга на 30%',
      'fact_2m_full_2': 'Нормализуется вес и состав тела',
      'fact_2m_full_3': 'Снижается риск диабета 2 типа на 25%',
      'fact_2m_full_4': 'Улучшается кровообращение и оксигенация тканей',
      'fact_2m_full_5': 'Снижается тревожность и улучшается психическое здоровье',
      'fact_2m_full_6': 'Восстанавливается либидо и гормональный баланс',

      'fact_3m_1': 'Печень восстановлена на 60-70%',
      'fact_3m_2': 'Нормализовался гормональный фон',
      'fact_3m_3': 'Улучшилось качество сна',
      'fact_3m_4': 'Снизился уровень холестерина',
      'fact_3m_5': 'Улучшилось состояние кожи',

      'fact_3m_full_1': 'Печень восстановлена на 60-70%',
      'fact_3m_full_2': 'Нормализуется гормональный фон',
      'fact_3m_full_3': 'Улучшается качество сна на 80%',
      'fact_3m_full_4': 'Снижается уровень холестерина ЛПНП',
      'fact_3m_full_5': 'Улучшается состояние кожи, волос и ногтей',
      'fact_3m_full_6': 'Восстанавливается микрофлора кишечника',

      'fact_6m_1': 'Печень восстановлена на 70-80%',
      'fact_6m_2': 'Риск рака печени снижен на 50%',
      'fact_6m_3': 'Полностью восстановился сон (все фазы)',
      'fact_6m_4': 'Улучшилась память и концентрация',
      'fact_6m_5': 'Снизился риск диабета 2 типа',

      'fact_6m_full_1': 'Печень восстановлена на 70-80%',
      'fact_6m_full_2': 'Риск рака печени снижен на 50%',
      'fact_6m_full_3': 'Полностью восстанавливается сон (все фазы)',
      'fact_6m_full_4': 'Улучшается память и концентрация на 60%',
      'fact_6m_full_5': 'Снижается риск диабета 2 типа на 40%',
      'fact_6m_full_6': 'Нормализуется психическое здоровье',

      'fact_year_1': 'Печень восстановлена на 90-95%',
      'fact_year_2': 'Риск сердечных заболеваний снижен на 50%',
      'fact_year_3': 'Нормализованы все показатели крови',
      'fact_year_4': 'Риск инсульта снижен на 40%',
      'fact_year_5': 'Значительно снижен риск рака печени и поджелудочной',

      'fact_year_full_1': 'Печень восстановлена на 90-95%',
      'fact_year_full_2': 'Риск сердечных заболеваний снижен на 50%',
      'fact_year_full_3': 'Нормализованы все показатели крови',
      'fact_year_full_4': 'Риск инсульта снижен на 40%',
      'fact_year_full_5': 'Значительно снижен риск рака печени и поджелудочной',
      'fact_year_full_6': 'Полное восстановление когнитивных функций',

      'hangover_title_1': 'Вчера было тяжело?',
      'hangover_title_2': 'Похмелье? Помни:',
      'hangover_title_3': 'Твой организм восстанавливается',
      'hangover_title_4': 'Пора возвращаться на путь',
      'hangover_title_5': 'Каждый день — новый старт',
      'hangover_title_6': 'У тебя всё получится',
      'hangover_title_7': 'Маленькие шаги, большие результаты',
      'hangover_title_8': 'Твой будущий «я» благодарит тебя',
      'hangover_title_9': 'Выбирай прогресс',
      'hangover_title_10': 'Один день за раз',

      'hangover_1_point_1': 'Мозг всё ещё восстанавливается',
      'hangover_1_point_2': 'Гидратация — ключ к успеху',
      'hangover_1_point_3': 'Сэкономь деньги сегодня',
      'hangover_2_point_1': 'Алкоголь нарушает сон',
      'hangover_2_point_2': 'Фокус улучшается без него',
      'hangover_2_point_3': 'Сердечный ритм нормализуется',
      'hangover_3_point_1': 'Когнитивные функции возвращаются',
      'hangover_3_point_2': 'Ты король своей жизни',
      'hangover_3_point_3': 'Продуктивность растёт',
      'hangover_4_point_1': 'Математика становится легче',
      'hangover_4_point_2': 'Утра становятся ярче',
      'hangover_4_point_3': 'Открой новый потенциал',
      'hangover_5_point_1': 'Меньше нагрузки на сердце',
      'hangover_5_point_2': 'Глаза становятся яснее',
      'hangover_5_point_3': 'Дыхание углубляется',
      'hangover_6_point_1': 'Уровень энергии стабилизируется',
      'hangover_6_point_2': 'Ты на верном пути',
      'hangover_6_point_3': 'Здоровье восстанавливается',
      'hangover_7_point_1': 'Тело перезагружается',
      'hangover_7_point_2': 'Качество сна улучшается',
      'hangover_7_point_3': 'Мотивация наполняется',
      'hangover_8_point_1': 'Лучшее общение',
      'hangover_8_point_2': 'Движения становятся легче',
      'hangover_8_point_3': 'Празднуй маленькие победы',
      'hangover_9_point_1': 'Нет потраченных впустую денег',
      'hangover_9_point_2': 'Сбережения растут',
      'hangover_9_point_3': 'Побалуй себя вместо этого',
      'hangover_10_point_1': 'Вес стабилизируется',
      'hangover_10_point_2': 'Приходят светлые идеи',
      'hangover_10_point_3': 'Ты побеждаешь',

      // НОВЫЕ КЛЮЧИ ДЛЯ ДОСТИЖЕНИЙ
      'achievements': 'Достижения',
      'all_achievements': 'Все',
      'ach_drink_3_title': 'Профи выживания',
      'ach_drink_3_desc': 'Три дня подряд во тьме? Выжил? Ты — профессионал.',
      'ach_drink_7_title': 'Мастер утреннего стыда',
      'ach_drink_7_desc': '7 дней без передышки? Твоя печень уже подала сигнал SOS.',
      'ach_drink_14_title': 'Меценат алкогольной индустрии',
      'ach_drink_14_desc': 'Каждые выходные ты спонсируешь чью-то яхту',
      'ach_drink_30_title': 'Эксперт по Утреннему Выживанию',
      'ach_drink_30_desc': 'Ты знаешь 1001 способ ожить с утра',

      'ach_sober_7_title': 'Скупой рыцарь',
      'ach_sober_7_desc': 'Твой кошелёк толстый, а голова — ясная',
      'ach_sober_14_title': 'Печень в отпуске',
      'ach_sober_14_desc': 'Твоя печень наконец-то ушла в spa-салон',
      'ach_sober_21_title': 'Враг местных баров',
      'ach_sober_21_desc': 'Бармены при виде тебя плачут в пустые бокалы',
      'ach_sober_30_title': 'Король трезвых утр',
      'ach_sober_30_desc': 'Ты помнишь, как лег спать. И как встали. И всё между.',
      'ach_sober_60_title': 'Угроза алкогольной индустрии',
      'ach_sober_60_desc': 'Твоя трезвость пугает производителей',
      'ach_sober_90_title': 'Самоконтроль: уровень бог',
      'ach_sober_90_desc': 'Ты держишь себя в руках, даже когда все вокруг теряют головы',
      'ach_sober_180_title': 'Сам себе детокс-центр',
      'ach_sober_180_desc': 'Сэкономил кучу денег на капельницах',
      'ach_sober_365_title': 'Хозяин своих мозгов',
      'ach_sober_365_desc': 'Твой мозг наконец-то производит дофамин сам',

      'ach_sport_8_title': 'Жертва фитнеса',
      'ach_sport_8_desc': 'Ты добровольно платишь деньги за право испытывать боль!',
      'ach_sport_12_title': 'Фитнес-маньяк',
      'ach_sport_12_desc': 'Крепатура стала твоим постоянным спутником!',
      'ach_sport_50_title': 'Страдалец',
      'ach_sport_50_desc': 'Твое тело постоянно где-то болит, но ты называешь это "прогрессом"!',
      'ach_sport_100_title': 'Гуру самоистязания',
      'ach_sport_100_desc': 'Садистское удовольствие от боли стало твоим смыслом жизни!',

      'condition_drinking_days': '%1 дней подряд',
      'condition_sober_days': '%1 трезвых дней подряд',
      'condition_sport_count': '%1 тренировок за %2 дней',
      'condition_sober_new_year': 'Провести 31 декабря без алкоголя',
      'condition_sport_new_year': 'Потренироваться 31 декабря',

      'ach_milestone_146_title': 'Пирамида Хеопса',
      'ach_milestone_146_desc': 'Десятки тысяч рабов строили это без воды и виски. А ты просто поднялся.',
      'ach_milestone_319_title': 'Крайслер-билдинг',
      'ach_milestone_319_desc': 'Шпиль острее, чем твоя тоска по рюмке.',
      'ach_milestone_443_title': 'Эмпайр-стейт-билдинг',
      'ach_milestone_443_desc': 'Кинг-Конг карабкался сюда ради красотки. А ты — ради ачивки и без выпивки.',
      'ach_milestone_1234_title': 'Ай-Петри',
      'ach_milestone_1234_desc': 'Поднимался, потел, не пил. Итог — вид на Ялту. Оно того стоило?',
      'ach_milestone_4810_title': 'Монблан',
      'ach_milestone_4810_desc': 'Спорт, трезвость, дисциплина. И вот ты на вершине. Где шампанское? А, нельзя.',
      'ach_milestone_5642_title': 'Эльбрус',
      'ach_milestone_5642_desc': 'Столько недель без алкоголя. Кислорода мало, зато совесть чиста.',
      'ach_milestone_7010_title': 'Хан Тенгри',
      'ach_milestone_7010_desc': 'Выше только небо. Но там тоже нет бара. Зато есть вид.',
      'ach_milestone_8848_title': 'Эверест',
      'ach_milestone_8848_desc': 'Ты на крыше мира. Обратный билет — пешком. Главное, не расслабляйся.',

      //Ачивки для погружения
      'ach_milestone_202_negative_title': 'Голубая дыра',
      'ach_milestone_202_negative_desc': 'Узкая, глубокая, тёмная. Как твоя жизнь после пятницы.',
      'ach_milestone_1642_negative_title': 'Байкал',
      'ach_milestone_1642_negative_desc': 'Самое глубокое пресное озеро. Твой организм теперь тоже пресный. И мёртвый.',
      'ach_milestone_3800_negative_title': 'Титаник',
      'ach_milestone_3800_negative_desc': 'Ледяная могила Титаника. И твоя - в процессе.',
      'ach_milestone_6066_negative_title': 'Атакамская впадина',
      'ach_milestone_6066_negative_desc': 'Огненный пояс Земли. Твоя печень сейчас тоже в эпицентре.',
      'ach_milestone_10047_negative_title': 'Кермадек',
      'ach_milestone_10047_negative_desc': 'Здесь раздавило глубоководного «Нерея». А ты - ничего, крепкий орешек.',
      'ach_milestone_11022_negative_title': 'Марианская впадина',
      'ach_milestone_11022_negative_desc': 'Ты на дне. Буквально. Хуже уже не будет. Или будет?',
      'condition_milestone_positive': '%1 метра над уровнем моря',
      'condition_milestone_negative': '%1 метра под водой',

      'no_achievements_yet': 'Пока нет достижений',

      //Окно оценки
      'review_title': 'Дай пять!',
      'review_message': 'Потратил кучу времени на заполнение календаря – не будь свиньёй, поставь звёздочку в Google Play. А если бесит – стукни единицу, я исправлюсь.',
      'review_rate_button': 'Оценить',
      'review_later_button': 'Отстань',
      'review_later_message': 'Ок, но я ж не отстану',

      //Рейтинги
      'top_100': 'Герои трезвости',
      'bottom_100': 'АлкоЛегенды',
      'menu_user_profile': 'Профиль',
      'menu_user_profile_subtitle': 'Имя и участие в рейтингах',
      'user_name_label': 'Ваше имя',
      'user_ranking_toggle': 'Хочу участвовать в рейтингах',
      'save_button': 'Сохранить',
      'error_username_empty': 'Имя не может быть пустым',
      'error_username_too_short': 'Минимум 3 символа',
      'error_username_too_long': 'Максимум 20 символов',
      'error_username_already_exists': 'Это имя уже занято',
      'error_missing_token': 'Ошибка авторизации',
      'error_unauthorized': 'Ошибка авторизации. Попробуйте позже.',
      'no_internet':'Нет интернета. Проверьте подключение.',
      'error_username_invalid_characters': 'Разрешены латинские буквы, цифры, подчеркивания и дефисы.',
      'error_username_contains_space':'Имя не должно содержать пробелов',
      'profile_needed': 'Чтобы видеть рейтинги, заполните профиль',
      'setup_profile': 'Заполнить профиль',
      'retry': 'Повторить',
      'no_leaderboard_data': 'Нет данных',
      'rating_not_participating': 'Вы не участвуете в рейтингах',
      'rating_participate_button': 'Участвовать',

      // для топ-3 попапов
      'top_1_place_title': 'Царь горы',
      'top_1_place_description': 'Ты на вершине! Но помни: чем выше, тем больнее падать.',
      'top_2_place_title': 'Серебряный призер',
      'top_2_place_description': 'Почти у цели. Ещё чуть-чуть и ты станешь первым... или нет.',
      'top_3_place_title': 'Бронзовые боец',
      'top_3_place_description': 'Ты в тройке лидеров. Поднажми.',
      'bottom_1_place_title': 'Алкогодзилла!',
      'bottom_1_place_description': 'Ты - номер один в самом сомнительном рейтинге. Гордишься?',
      'bottom_2_place_title': 'Верный соратник Бахуса',
      'bottom_2_place_description': 'Ты почти чемпион по возлияниям. Остановись.',
      'bottom_3_place_title': 'Бронзовый гуляка',
      'bottom_3_place_description': 'Ты в тройке самых стойких алкотуристов. Держи кубок, он тебе пригодится.',

      // Туториал – страница профиля
      'tutorial_title_profile': 'Участвуй в рейтингах!',
      'tutorial_desc_profile': 'Хочешь знать, кто круче покоряет вершины, а кто сильнее погружается на дно? Участвуй в рейтингах!',
      'profile_guest_title': 'Вы не вошли',
      'profile_guest_message': 'Войдите через Google, чтобы участвовать в рейтингах.',

    },
  };

  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  String translate(String key, [List<Object>? args]) {
    String? value = _localizedValues[locale.languageCode]?[key] ?? key;

    if (args != null && args.isNotEmpty) {
      for (int i = 0; i < args.length; i++) {
        value = value!.replaceAll('%${i + 1}', args[i].toString());
      }
    }

    return value ?? key;
  }

  String get dayShort => translate('day_short');

  String get exportShareSubject => 'Wobbly Data Export';
  String get exportShareText => 'Here is my Wobbly data export file.';
  String get exportError => 'Export failed';

  // Геттеры для удобства
  String get calendarTabTitle => translate('calendar_tab_title');
  String get statTabTitle => translate('stat_tab_title');
  String get ratingsTabTitle => translate('ratings_tab_title');
  String get drinkLogPrompt => translate('drink_log_prompt');
  String get orSportPrompt => translate('or_sport_prompt');
  String get ok => translate('OK');
  String get errorFutureDate => translate('error_future_date');

  // Геттеры для туториала
  String get tutorialTitle1 => translate('tutorial_title_1');
  String get tutorialDesc1 => translate('tutorial_desc_1');
  String get tutorialTitle2 => translate('tutorial_title_2');
  String get tutorialDesc2 => translate('tutorial_desc_2');
  String get tutorialTitle3 => translate('tutorial_title_3');
  String get tutorialDesc3 => translate('tutorial_desc_3');
  String get tutorialTitle4 => translate('tutorial_title_4');
  String get tutorialDesc4 => translate('tutorial_desc_4');
  String get tutorialTitle5 => translate('tutorial_title_5');
  String get tutorialDesc5 => translate('tutorial_desc_5');
  String get tutorialNextButton => translate('tutorial_next_button');
  String get tutorialStartSufferingButton => translate('tutorial_start_suffering_button');

  // Геттеры для day_selection_sheet.dart
  String get drinkPrompt => translate('drink_prompt');
  String get littleLabel => translate('little_label');
  String get mediumLabel => translate('medium_label');
  String get heavyLabel => translate('heavy_label');
  String get sportPrompt => translate('sport_prompt');
  String get sportLabel => translate('sport_label');
  String get okButton => translate('ok_button');

// Геттеры для stats_screen.dart
  String get yearSuffix => translate('year_suffix');
  String get selectYear => translate('select_year');
  String get currentSoberStreak => translate('current_sober_streak');
  String get drinkingStreakDays => translate('drinking_streak_days');
  String get maxSoberStreak => translate('max_sober_streak');
  String get totalDrinkingDays => translate('total_drinking_days');
  String get totalSoberDays => translate('total_sober_days');
  String get sportDaysLabel => translate('sport_days_label');
  String get alcoholVsSportTitle => translate('alcohol_vs_sport_title');

  // Геттеры для дней недели
  String get mondayShort => translate('monday_short');
  String get tuesdayShort => translate('tuesday_short');
  String get wednesdayShort => translate('wednesday_short');
  String get thursdayShort => translate('thursday_short');
  String get fridayShort => translate('friday_short');
  String get saturdayShort => translate('saturday_short');
  String get sundayShort => translate('sunday_short');

  // Геттеры для месяцев
  String get january => translate('january');
  String get february => translate('february');
  String get march => translate('march');
  String get april => translate('april');
  String get may => translate('may');
  String get june => translate('june');
  String get july => translate('july');
  String get august => translate('august');
  String get september => translate('september');
  String get october => translate('october');
  String get november => translate('november');
  String get december => translate('december');

  // Геттеры для заголовков
  String get motivationTitleNone => translate('motivation_title_none');
  String get motivationTitleSport => translate('motitle_sport');
  String get motivationTitleLittle => translate('motitle_little');
  String get motivationTitleLittleSport => translate('motitle_little_sport');
  String get motivationTitleMedium => translate('motitle_medium');
  String get motivationTitleHeavy => translate('motitle_heavy');

  // Геттеры для описаний статистики
  String get statSoberStreakTitle => translate('stat_sober_streak_title');
  String get statSoberStreakDescription => translate('stat_sober_streak_description');
  String get statDrinkingStreakTitle => translate('stat_drinking_streak_title');
  String get statDrinkingStreakDescription => translate('stat_drinking_streak_description');
  String get statMaxSoberStreakTitle => translate('stat_max_sober_streak_title');
  String get statMaxSoberStreakDescription => translate('stat_max_sober_streak_description');
  String get statTotalDrinkingDaysTitle => translate('stat_total_drinking_days_title');
  String get statTotalDrinkingDaysDescription => translate('stat_total_drinking_days_description');
  String get statTotalSoberDaysTitle => translate('stat_total_sober_days_title');
  String get statTotalSoberDaysDescription => translate('stat_total_sober_days_description');
  String get statLittleTitle => translate('stat_drink_level_little_title');
  String get statLittleDescription => translate('stat_drink_level_little_description');
  String get statMediumTitle => translate('stat_drink_level_medium_title');
  String get statMediumDescription => translate('stat_drink_level_medium_description');
  String get statHeavyTitle => translate('stat_drink_level_heavy_title');
  String get statHeavyDescription => translate('stat_drink_level_heavy_description');
  String get statSportDaysTitle => translate('stat_sport_days_title');
  String get statSportDaysDescription => translate('stat_sport_days_description');

  String get menuLanguage => translate('menu_language');
  String get menuLanguageSubtitle => translate('menu_language_subtitle');
  String get languageEnglish => translate('language_english');
  String get languageRussian => translate('language_russian');
  String get languageCurrent => translate('language_current');
  String get switchToEnglish => translate('switch_to_english');
  String get switchToRussian => translate('switch_to_russian');
  String get settingsMenu => translate('settings_menu');
  String get menuExportTitle => translate('menu_export_title');
  String get menuExportSubtitle => translate('menu_export_subtitle');
  String get menuImportTitle => translate('menu_import_title');
  String get menuImportSubtitle => translate('menu_import_subtitle');
  String get menuRestoreTitle => translate('menu_restore_title');
  String get menuRestoreSubtitle => translate('menu_restore_subtitle');
  String get menuResetTitle => translate('menu_reset_title');
  String get menuResetSubtitle => translate('menu_reset_subtitle');
  String get menuTgTitle => translate('menu_tg_title');
  String get menuAchievementsTitle => translate('menu_achievements_title');
  String get menuVersionTitle => translate('menu_version_title');
  String get about => translate('about');
  String get back => translate('back');
  String get appTitle => translate('WOBBLY');
  String get appSubtitle => translate('subtitle');
  String get appOriginStoryPart1 => translate('app_origin_story_part1');
  String get appOriginStoryPart2 => translate('app_origin_story_part2');
  String get aboutCreatorDescription => translate('about_creator_description');
  String get aboutCapabilitiesTitle => translate('about_capabilities_title');
  String get featureStatsTitle => translate('feature_stats_title');
  String get featureStatsDesc => translate('feature_stats_desc');
  String get featureAchievementsTitle => translate('feature_achievements_title');
  String get featureAchievementsDesc => translate('feature_achievements_desc');
  String get featurePrivacyTitle => translate('feature_privacy_title');
  String get featurePrivacyDesc => translate('feature_privacy_desc');
  String get achievementsResetNotificationTitle => translate('achievements_reset_notification_title');
  String get achievementsResetNotificationMessage => translate('achievements_reset_notification_message');
  String get alcoholLabel => translate('alcohol_label');
  String get sportLabelBar => translate('sport_label_bar');

  //Геттеры для окна оценки
  String get reviewTitle => translate('review_title');
  String get reviewMessage => translate('review_message');
  String get reviewRateButton => translate('review_rate_button');
  String get reviewLaterButton => translate('review_later_button');
  String get reviewLaterMessage => translate('review_later_message');

  String get errorUsernameInvalidCharacters => translate('error_username_invalid_characters');
  String get ratingNotParticipating => translate('rating_not_participating');
  String get ratingParticipateButton => translate('rating_participate_button');


  /// Возвращает случайную мотивационную фразу для категории (true = алкоголь, false = трезвость)
  String getRandomMotivationText(bool isDrinking) {
    int maxIndex;
    String prefix;
    if (isDrinking) {
      maxIndex = 17;
      prefix = 'motivation_drinking_';
    } else {
      maxIndex = 15;
      prefix = 'motivation_sober_';
    }
    final randomIndex = 1 + (DateTime.now().millisecondsSinceEpoch % maxIndex);
    final key = '$prefix$randomIndex';
    return translate(key);
  }

  // Метод для получения названия месяца по индексу (0-11)
  String getMonthName(int monthIndex) {
    switch (monthIndex) {
      case 0: return january;
      case 1: return february;
      case 2: return march;
      case 3: return april;
      case 4: return may;
      case 5: return june;
      case 6: return july;
      case 7: return august;
      case 8: return september;
      case 9: return october;
      case 10: return november;
      case 11: return december;
      default: return '';
    }
  }

  // методы для статусов
  String getUserStatusTitle(UserStatus status) {
    switch (status) {
      case UserStatus.sporty:
        return translate('status_sporty_title');
      case UserStatus.alcoholic:
        return translate('status_alcoholic_title');
      case UserStatus.boring:
        return translate('status_boring_title');
      case UserStatus.balanced:
        return translate('status_balanced_title');
      case UserStatus.moderateDrinker:
        return translate('status_moderate_drinker_title');
      case UserStatus.activeLifestyle:
        return translate('status_active_lifestyle_title');
      case UserStatus.weekendWarrior:
        return translate('status_weekend_warrior_title');
      case UserStatus.soberEnthusiast:
        return translate('status_sober_enthusiast_title');
      case UserStatus.sportsFanatic:
        return translate('status_sports_fanatic_title');
      case UserStatus.partyAnimal:
        return translate('status_party_animal_title');
      case UserStatus.alcoCyborg:
        return translate('status_alco_cyborg_title');
    }
  }

  String getUserStatusDescription(UserStatus status) {
    switch (status) {
      case UserStatus.sporty:
        return translate('status_sporty_description');
      case UserStatus.alcoholic:
        return translate('status_alcoholic_description');
      case UserStatus.boring:
        return translate('status_boring_description');
      case UserStatus.balanced:
        return translate('status_balanced_description');
      case UserStatus.moderateDrinker:
        return translate('status_moderate_drinker_description');
      case UserStatus.activeLifestyle:
        return translate('status_active_lifestyle_description');
      case UserStatus.weekendWarrior:
        return translate('status_weekend_warrior_description');
      case UserStatus.soberEnthusiast:
        return translate('status_sober_enthusiast_description');
      case UserStatus.sportsFanatic:
        return translate('status_sports_fanatic_description');
      case UserStatus.partyAnimal:
        return translate('status_party_animal_description');
      case UserStatus.partyAnimal:
        return translate('status_party_animal_description');
      case UserStatus.alcoCyborg:
        return translate('status_alco_cyborg_description');
    }
  }

  // Метод для получения списка коротких названий дней недели
  List<String> get weekdaysShort => [
    mondayShort,
    tuesdayShort,
    wednesdayShort,
    thursdayShort,
    fridayShort,
    saturdayShort,
    sundayShort,
  ];

  // Метод для получения списка названий месяцев
  List<String> get monthNames => [
    january,
    february,
    march,
    april,
    may,
    june,
    july,
    august,
    september,
    october,
    november,
    december,
  ];

  String getTutorialImageAsset(int index) {
    final lang = locale.languageCode;
    return 'assets/tutorial/${lang}_tutorial${index + 1}.png';
  }

  String getTutorialProfileImageAsset() {
    final lang = locale.languageCode;
    return 'assets/tutorial/${lang}_profile.png';
  }

  // Метод для получения данных страницы по индексу
  TutorialPageData getTutorialPageData(int index) {
    switch (index) {
      case 0:
        return TutorialPageData(
          title: tutorialTitle1,
          description: tutorialDesc1,
          icon: Icons.help_outline,
          imageAsset: getTutorialImageAsset(0),
        );
      case 1:
        return TutorialPageData(
          title: tutorialTitle2,
          description: tutorialDesc2,
          icon: Icons.local_bar,
          imageAsset: getTutorialImageAsset(1),
        );
      case 2:
        return TutorialPageData(
          title: tutorialTitle4,        // старый текст про статистику
          description: tutorialDesc4,
          icon: Icons.bar_chart,
          imageAsset: getTutorialImageAsset(2),
        );
      case 3:
        return TutorialPageData(
          title: translate('tutorial_title_4_new'),
          description: translate('tutorial_desc_4_new'),
          icon: Icons.insights,
          imageAsset: getTutorialImageAsset(3),
        );
      case 4:
        return TutorialPageData(
          title: tutorialTitle5,
          description: tutorialDesc5,
          icon: Icons.shield,
          imageAsset: getTutorialImageAsset(4),
        );
      default:
        throw Exception('Invalid tutorial page index');
    }
  }

}

// Вспомогательный класс для данных страницы
class TutorialPageData {
  final String title;
  final String description;
  final IconData icon;
  final String imageAsset;

  TutorialPageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.imageAsset,
  });
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ru'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
